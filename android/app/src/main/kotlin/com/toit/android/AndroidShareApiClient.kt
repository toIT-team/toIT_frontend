package com.toit.android

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.net.Uri
import androidx.exifinterface.media.ExifInterface
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AndroidShareApiClient(private val context: Context) {
  private val tokenStore = AndroidTokenStore(context)
  private var accessToken: String = tokenStore.readAccessToken().orEmpty()
  private var refreshToken: String? = tokenStore.readRefreshToken()
  private val baseUrl: String = tokenStore.readBaseUrl().orEmpty().trimEnd('/')
  private val userId: Int = tokenStore.readUserId()

  fun hasRequiredAuth(): Boolean {
    return accessToken.isNotBlank() && baseUrl.isNotBlank()
  }

  fun fetchFolders(): List<AndroidShareFolder> {
    ensureConfigured()
    val url = url(
      "/page/home",
      mapOf(
        "todayDate" to todayString(),
      ),
    )
    val response = authorizedRequest(method = "GET", url = url)
    val folders = JSONObject(response).optJSONArray("folders") ?: JSONArray()
    return buildList {
      for (index in 0 until folders.length()) {
        val item = folders.optJSONObject(index) ?: continue
        val folder = AndroidShareFolder(
          id = item.optIntCompat("foldersId"),
          name = item.optString("name"),
          isDefault = item.optBooleanCompat("isDefault"),
        )
        if (folder.id > 0 && folder.name.isNotBlank()) add(folder)
      }
    }
  }

  fun createText(folderId: Int, textContent: String) {
    ensureConfigured()
    val body = JSONObject()
      .put("foldersIdList", JSONArray().put(folderId))
      .put("textContent", textContent)
    authorizedRequest(
      method = "POST",
      url = url("/texts"),
      contentType = "application/json",
      body = body.toString().toByteArray(Charsets.UTF_8),
    )
  }

  fun createLink(folderId: Int, linksUrl: String, memo: String) {
    ensureConfigured()
    val preview = runCatching { fetchLinkPreview(linksUrl) }.getOrNull()
    val textContent = memo.ifBlank { preview?.textContent.orEmpty() }
    val body = JSONObject()
      .put("foldersIdList", JSONArray().put(folderId))
      .put("linksUrl", linksUrl)

    if (textContent.isNotBlank()) body.put("textContent", textContent)
    preview?.linksName?.takeIf { it.isNotBlank() }?.let { body.put("linksName", it) }
    preview?.linksThumbnail?.takeIf { it.isNotBlank() }?.let { body.put("linksThumbnail", it) }

    authorizedRequest(
      method = "POST",
      url = url("/links"),
      contentType = "application/json",
      body = body.toString().toByteArray(Charsets.UTF_8),
    )
  }

  fun uploadImage(folderId: Int, uri: Uri, fileName: String, mimeType: String?, memo: String) {
    uploadAttachment(
      attachmentsType = "IMAGE",
      folderId = folderId,
      uri = uri,
      fileName = fileName,
      mimeType = mimeType,
      memo = memo,
    )
  }

  fun uploadFile(folderId: Int, uri: Uri, fileName: String, mimeType: String?, memo: String) {
    uploadAttachment(
      attachmentsType = "FILE",
      folderId = folderId,
      uri = uri,
      fileName = fileName,
      mimeType = mimeType,
      memo = memo,
    )
  }

  private fun fetchLinkPreview(linksUrl: String): AndroidLinkPreview {
    val body = JSONObject().put("linksUrl", linksUrl)
    val response = authorizedRequest(
      method = "POST",
      url = url("/links/preview"),
      contentType = "application/json",
      body = body.toString().toByteArray(Charsets.UTF_8),
    )
    val json = JSONObject(response)
    return AndroidLinkPreview(
      linksName = json.optString("linksName"),
      textContent = json.optString("textContent"),
      linksThumbnail = json.optString("linksThumbnail"),
    )
  }

  private fun uploadAttachment(
    attachmentsType: String,
    folderId: Int,
    uri: Uri,
    fileName: String,
    mimeType: String?,
    memo: String,
  ) {
    ensureConfigured()
    val fileBytes = context.contentResolver.openInputStream(uri)?.use { input ->
      input.readBytes()
    } ?: throw IOException("공유 파일을 읽을 수 없습니다.")
    if (fileBytes.isEmpty()) throw IOException("공유 파일을 읽을 수 없습니다.")

    val uploadPayload = if (attachmentsType == "IMAGE") {
      normalizeImageForUpload(
        fileBytes = fileBytes,
        fileName = fileName,
        mimeType = mimeType,
      )
    } else {
      AndroidAttachmentUploadPayload(
        bytes = fileBytes,
        fileName = fileName,
        contentType = resolveContentType(fileName, mimeType),
        width = null,
        height = null,
      )
    }
    val presignResponse = presignAttachment(
      attachmentsType = attachmentsType,
      folderId = folderId,
      memo = memo,
      fileName = uploadPayload.fileName,
      fileSize = uploadPayload.bytes.size,
      contentType = uploadPayload.contentType,
      width = uploadPayload.width,
      height = uploadPayload.height,
    )
    uploadToS3(
      uploadUrl = presignResponse.uploadUrl,
      fileBytes = uploadPayload.bytes,
      contentType = uploadPayload.contentType,
    )
    confirmAttachment(
      attachmentsType = attachmentsType,
      folderId = folderId,
      memo = memo,
      objectKey = presignResponse.objectKey,
      fileName = uploadPayload.fileName,
      fileSize = uploadPayload.bytes.size,
      contentType = uploadPayload.contentType,
      width = uploadPayload.width,
      height = uploadPayload.height,
    )
  }

  private fun normalizeImageForUpload(
    fileBytes: ByteArray,
    fileName: String,
    mimeType: String?,
  ): AndroidAttachmentUploadPayload {
    val contentType = resolveContentType(fileName, mimeType)
    val fallback = AndroidAttachmentUploadPayload(
      bytes = fileBytes,
      fileName = fileName,
      contentType = contentType,
      width = null,
      height = null,
    )

    val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
    BitmapFactory.decodeByteArray(fileBytes, 0, fileBytes.size, bounds)
    if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return fallback

    val orientation = runCatching {
      ExifInterface(ByteArrayInputStream(fileBytes)).getAttributeInt(
        ExifInterface.TAG_ORIENTATION,
        ExifInterface.ORIENTATION_NORMAL,
      )
    }.getOrDefault(ExifInterface.ORIENTATION_NORMAL)

    if (orientation == ExifInterface.ORIENTATION_NORMAL ||
      orientation == ExifInterface.ORIENTATION_UNDEFINED
    ) {
      return fallback.copy(width = bounds.outWidth, height = bounds.outHeight)
    }

    val source = BitmapFactory.decodeByteArray(fileBytes, 0, fileBytes.size) ?: return fallback
    val matrix = Matrix().apply {
      when (orientation) {
        ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> preScale(-1f, 1f)
        ExifInterface.ORIENTATION_ROTATE_180 -> postRotate(180f)
        ExifInterface.ORIENTATION_FLIP_VERTICAL -> {
          postRotate(180f)
          preScale(-1f, 1f)
        }
        ExifInterface.ORIENTATION_TRANSPOSE -> {
          postRotate(90f)
          preScale(-1f, 1f)
        }
        ExifInterface.ORIENTATION_ROTATE_90 -> postRotate(90f)
        ExifInterface.ORIENTATION_TRANSVERSE -> {
          postRotate(-90f)
          preScale(-1f, 1f)
        }
        ExifInterface.ORIENTATION_ROTATE_270 -> postRotate(-90f)
      }
    }

    val rotated = Bitmap.createBitmap(source, 0, 0, source.width, source.height, matrix, true)
    val normalizedBytes = ByteArrayOutputStream().use { output ->
      rotated.compress(Bitmap.CompressFormat.JPEG, 95, output)
      output.toByteArray()
    }
    val width = rotated.width
    val height = rotated.height
    if (rotated !== source) source.recycle()
    rotated.recycle()

    return AndroidAttachmentUploadPayload(
      bytes = normalizedBytes,
      fileName = replaceExtension(fileName, "jpg"),
      contentType = "image/jpeg",
      width = width,
      height = height,
    )
  }

  private fun presignAttachment(
    attachmentsType: String,
    folderId: Int,
    memo: String,
    fileName: String,
    fileSize: Int,
    contentType: String,
    width: Int?,
    height: Int?,
  ): AndroidPresignResponse {
    val file = JSONObject()
      .put("contentType", contentType)
      .put("fileName", fileName)
      .put("fileSize", fileSize)
    if (width != null) file.put("width", width)
    if (height != null) file.put("height", height)
    val body = JSONObject()
      .put("foldersIdList", JSONArray().put(folderId))
      .put("attachmentsType", attachmentsType)
      .put("textContent", memo)
      .put("files", JSONArray().put(file))

    val response = authorizedRequest(
      method = "POST",
      url = url("/attachments/presign"),
      contentType = "application/json",
      body = body.toString().toByteArray(Charsets.UTF_8),
    )
    val json = response.trim().let {
      if (it.startsWith("[")) JSONArray(it).optJSONObject(0) else JSONObject(it)
    } ?: throw AndroidShareApiError.InvalidResponse

    val objectKey = json.optString("objectKey")
    val uploadUrl = json.optString("uploadUrl")
    if (objectKey.isBlank() || uploadUrl.isBlank()) throw AndroidShareApiError.InvalidResponse
    return AndroidPresignResponse(objectKey = objectKey, uploadUrl = uploadUrl)
  }

  private fun uploadToS3(uploadUrl: String, fileBytes: ByteArray, contentType: String) {
    val connection = (URL(uploadUrl).openConnection() as HttpURLConnection).apply {
      requestMethod = "PUT"
      connectTimeout = 60_000
      readTimeout = 60_000
      setRequestProperty("Content-Type", contentType)
      setRequestProperty("Content-Length", fileBytes.size.toString())
      doOutput = true
    }

    try {
      connection.outputStream.use { it.write(fileBytes) }
      val status = connection.responseCode
      if (status !in 200..399) {
        throw AndroidShareApiError.ServerError(status)
      }
    } finally {
      connection.disconnect()
    }
  }

  private fun confirmAttachment(
    attachmentsType: String,
    folderId: Int,
    memo: String,
    objectKey: String,
    fileName: String,
    fileSize: Int,
    contentType: String,
    width: Int?,
    height: Int?,
  ) {
    val file = JSONObject()
      .put("objectKey", objectKey)
      .put("fileName", fileName)
      .put("fileSize", fileSize)
      .put("contentType", contentType)
    if (width != null) file.put("width", width)
    if (height != null) file.put("height", height)
    val body = JSONObject()
      .put("foldersIdList", JSONArray().put(folderId))
      .put("attachmentsType", attachmentsType)
      .put("textContent", memo)
      .put("files", JSONArray().put(file))

    authorizedRequest(
      method = "POST",
      url = url("/attachments/confirm"),
      contentType = "application/json",
      body = body.toString().toByteArray(Charsets.UTF_8),
    )
  }

  private fun authorizedRequest(
    method: String,
    url: URL,
    contentType: String? = null,
    body: ByteArray? = null,
    timeoutMillis: Int = 15_000,
  ): String {
    val first = request(
      method = method,
      url = url,
      accessToken = accessToken,
      contentType = contentType,
      body = body,
      timeoutMillis = timeoutMillis,
    )
    if (first.statusCode != HttpURLConnection.HTTP_UNAUTHORIZED) {
      first.throwIfFailed()
      return first.body
    }

    if (!reissueAccessToken()) {
      throw AndroidShareApiError.Unauthorized
    }

    val retry = request(
      method = method,
      url = url,
      accessToken = accessToken,
      contentType = contentType,
      body = body,
      timeoutMillis = timeoutMillis,
    )
    retry.throwIfFailed()
    return retry.body
  }

  private fun request(
    method: String,
    url: URL,
    accessToken: String,
    contentType: String?,
    body: ByteArray?,
    timeoutMillis: Int,
  ): ApiResponse {
    val connection = (url.openConnection() as HttpURLConnection).apply {
      requestMethod = method
      connectTimeout = timeoutMillis
      readTimeout = timeoutMillis
      setRequestProperty("Authorization", "Bearer $accessToken")
      setRequestProperty("Accept", "application/json")
      if (contentType != null) setRequestProperty("Content-Type", contentType)
      if (body != null) {
        doOutput = true
        setRequestProperty("Content-Length", body.size.toString())
      }
    }

    return try {
      if (body != null) {
        connection.outputStream.use { it.write(body) }
      }
      val status = connection.responseCode
      val stream = if (status in 200..299) connection.inputStream else connection.errorStream
      val responseBody = stream?.bufferedReader(Charsets.UTF_8)?.use { it.readText() }.orEmpty()
      ApiResponse(status, responseBody)
    } finally {
      connection.disconnect()
    }
  }

  private fun reissueAccessToken(): Boolean {
    val currentRefreshToken = refreshToken?.takeIf { it.isNotBlank() } ?: return false
    val body = JSONObject().put("refreshToken", currentRefreshToken)
      .toString()
      .toByteArray(Charsets.UTF_8)
    val connection = (url("/api/auth/reissue").openConnection() as HttpURLConnection).apply {
      requestMethod = "POST"
      connectTimeout = 15_000
      readTimeout = 15_000
      setRequestProperty("Content-Type", "application/json")
      setRequestProperty("Accept", "application/json")
      doOutput = true
    }

    return try {
      connection.outputStream.use { it.write(body) }
      val status = connection.responseCode
      if (status !in 200..299) return false
      val response = connection.inputStream.bufferedReader(Charsets.UTF_8).use { it.readText() }
      val json = JSONObject(response)
      val newAccessToken = json.optString("accessToken")
      if (newAccessToken.isBlank()) return false
      val newRefreshToken = json.optString("refreshToken").takeIf { it.isNotBlank() }

      accessToken = newAccessToken
      refreshToken = newRefreshToken ?: currentRefreshToken
      tokenStore.save(
        accessToken = accessToken,
        refreshToken = refreshToken.orEmpty(),
        userId = userId,
        baseUrl = baseUrl,
      )
      true
    } finally {
      connection.disconnect()
    }
  }

  private fun ensureConfigured() {
    if (!hasRequiredAuth()) throw AndroidShareApiError.Unauthorized
  }

  private fun url(path: String, query: Map<String, String> = emptyMap()): URL {
    val normalizedPath = if (path.startsWith("/")) path else "/$path"
    val encodedQuery = query.entries.joinToString("&") { (key, value) ->
      "${encode(key)}=${encode(value)}"
    }
    val target = buildString {
      append(baseUrl)
      append(normalizedPath)
      if (encodedQuery.isNotBlank()) {
        append("?")
        append(encodedQuery)
      }
    }
    return URL(target)
  }

  private fun encode(value: String): String {
    return URLEncoder.encode(value, "UTF-8")
  }

  private fun todayString(): String {
    return SimpleDateFormat("yyyy-MM-dd", Locale.KOREA).format(Date())
  }

  private data class ApiResponse(val statusCode: Int, val body: String) {
    fun throwIfFailed() {
      when (statusCode) {
        in 200..299 -> return
        HttpURLConnection.HTTP_UNAUTHORIZED -> throw AndroidShareApiError.Unauthorized
        else -> throw AndroidShareApiError.ServerError(statusCode)
      }
    }
  }
}

data class AndroidShareFolder(
  val id: Int,
  val name: String,
  val isDefault: Boolean,
)

private data class AndroidLinkPreview(
  val linksName: String,
  val textContent: String,
  val linksThumbnail: String,
)

private data class AndroidPresignResponse(
  val objectKey: String,
  val uploadUrl: String,
)

private data class AndroidAttachmentUploadPayload(
  val bytes: ByteArray,
  val fileName: String,
  val contentType: String,
  val width: Int?,
  val height: Int?,
)

sealed class AndroidShareApiError(message: String) : Exception(message) {
  object Unauthorized : AndroidShareApiError("인증이 만료되었습니다. 앱에서 다시 로그인해주세요.")
  object InvalidResponse : AndroidShareApiError("서버 응답을 처리할 수 없습니다.")
  class ServerError(code: Int) : AndroidShareApiError("서버 오류가 발생했습니다. ($code)")
}

private fun replaceExtension(fileName: String, extension: String): String {
  val index = fileName.lastIndexOf('.')
  if (index <= 0) return "$fileName.$extension"
  return fileName.substring(0, index) + ".$extension"
}

private fun resolveContentType(fileName: String, mimeType: String?): String {
  if (!mimeType.isNullOrBlank() && mimeType != "*/*") return mimeType
  return when (fileName.substringAfterLast('.', "").lowercase(Locale.ROOT)) {
    "jpg", "jpeg" -> "image/jpeg"
    "png" -> "image/png"
    "webp" -> "image/webp"
    "gif" -> "image/gif"
    "heic", "heif" -> "image/heic"
    "pdf" -> "application/pdf"
    "doc" -> "application/msword"
    "docx" -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    "xls" -> "application/vnd.ms-excel"
    "xlsx" -> "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    "ppt" -> "application/vnd.ms-powerpoint"
    "pptx" -> "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    "zip" -> "application/zip"
    "txt" -> "text/plain"
    else -> "application/octet-stream"
  }
}

private fun JSONObject.optIntCompat(key: String): Int {
  val value = opt(key) ?: return 0
  return when (value) {
    is Number -> value.toInt()
    is String -> value.toIntOrNull() ?: 0
    else -> 0
  }
}

private fun JSONObject.optBooleanCompat(key: String): Boolean {
  val value = opt(key) ?: return false
  return when (value) {
    is Boolean -> value
    is Number -> value.toInt() != 0
    is String -> value.equals("true", ignoreCase = true)
    else -> false
  }
}

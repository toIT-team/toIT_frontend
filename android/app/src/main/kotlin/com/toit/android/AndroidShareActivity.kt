package com.toit.android

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Parcelable
import android.provider.OpenableColumns
import android.text.Editable
import android.text.TextWatcher
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import java.net.URLConnection

class AndroidShareActivity : Activity() {
  private companion object {
    const val MEMO_MAX_LENGTH = 1000

    val COLOR_GRAY_900: Int = Color.rgb(34, 34, 34)
    val COLOR_GRAY_600: Int = Color.rgb(128, 131, 156)
    val COLOR_BLUE_500: Int = Color.rgb(55, 155, 251)
    val COLOR_NEUTRAL_100: Int = Color.rgb(221, 221, 221)
    val COLOR_NEUTRAL_300: Int = Color.rgb(244, 246, 248)
  }

  private var folders = emptyList<AndroidShareFolder>()
  private var folderSearchQuery = ""
  private var selectedFolder: AndroidShareFolder? = null
  private val sharedItems = mutableListOf<SharedItem>()
  private val apiClient by lazy { AndroidShareApiClient(this) }
  private val dirtyStore by lazy { AndroidExternalSaveDirtyStore(this) }
  private lateinit var memoCounterView: TextView
  private lateinit var memoInput: EditText
  private lateinit var saveButton: TextView
  private lateinit var folderRow: LinearLayout

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    configureWindow()
    sharedItems.addAll(parseSharedItems(intent))
    setContentView(buildContentView())
    loadFolders()
  }

  private fun configureWindow() {
    requestWindowFeature(Window.FEATURE_NO_TITLE)
    window.setBackgroundDrawableResource(android.R.color.transparent)
    window.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
    window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
  }

  private fun buildContentView(): View {
    val root = FrameLayout(this).apply {
      setBackgroundColor(Color.argb(115, 0, 0, 0))
      layoutParams = FrameLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT,
      )
      setOnClickListener { finish() }
    }

    val sheet = LinearLayout(this).apply {
      orientation = LinearLayout.VERTICAL
      background = roundedTopDrawable(Color.WHITE, dp(24f))
      setPadding(dp(20f), dp(20f), dp(20f), dp(24f))
      isClickable = true
      isFocusable = true
      setOnClickListener { }
    }

    root.addView(
      sheet,
      FrameLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.WRAP_CONTENT,
        Gravity.BOTTOM,
      ),
    )

    sheet.addView(buildHeader())
    sheet.addView(space(20f))
    sheet.addView(buildFolderSearchBar())
    sheet.addView(space(22f))
    sheet.addView(buildFolderScroller())
    sheet.addView(space(28f))
    sheet.addView(buildMemoLabel())
    sheet.addView(space(18f))
    sheet.addView(buildMemoInput())
    sheet.addView(space(18f))
    sheet.addView(buildCounterRow())

    return root
  }

  private fun buildHeader(): View {
    return LinearLayout(this).apply {
      orientation = LinearLayout.HORIZONTAL
      gravity = Gravity.CENTER_VERTICAL

      addView(
        text(
          value = "보관함",
          sizeSp = 24f,
          color = COLOR_GRAY_900,
          weight = Typeface.BOLD,
        ),
      )

      addView(
        TextView(this@AndroidShareActivity),
        LinearLayout.LayoutParams(0, 1, 1f),
      )

      saveButton = text(
        value = "저장",
        sizeSp = 18f,
        color = COLOR_BLUE_500,
        weight = Typeface.BOLD,
      ).apply {
        setPadding(dp(10f), dp(6f), dp(0f), dp(6f))
        setOnClickListener { handleSave() }
      }
      addView(saveButton)
    }
  }

  private fun buildFolderSearchBar(): View {
    return LinearLayout(this).apply {
      orientation = LinearLayout.HORIZONTAL
      gravity = Gravity.CENTER_VERTICAL
      background = roundedDrawable(COLOR_NEUTRAL_300, dp(12f), 0, 0)
      setPadding(dp(18f), 0, dp(12f), 0)

      addView(
        SearchIconView(this@AndroidShareActivity),
        LinearLayout.LayoutParams(dp(30f), dp(30f)),
      )
      addView(space(widthDp = 10f, heightDp = 1f))

      val searchInput = EditText(this@AndroidShareActivity).apply {
        textSize = 22f
        setTextColor(COLOR_GRAY_900)
        setHintTextColor(COLOR_GRAY_600)
        hint = "보관함 입력"
        setSingleLine(true)
        background = null
        imeOptions = EditorInfo.IME_ACTION_SEARCH
        includeFontPadding = false
        setPadding(0, 0, 0, 0)
        addTextChangedListener(
          object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
              folderSearchQuery = s?.toString().orEmpty()
              renderFolderChips()
            }

            override fun afterTextChanged(s: Editable?) = Unit
          },
        )
      }
      addView(searchInput, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))

      addView(
        ClearIconView(this@AndroidShareActivity).apply {
          setOnClickListener { searchInput.text?.clear() }
        },
        LinearLayout.LayoutParams(dp(32f), dp(32f)),
      )
      layoutParams = LinearLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        dp(74f),
      )
    }
  }

  private fun buildFolderScroller(): View {
    folderRow = LinearLayout(this).apply {
      orientation = LinearLayout.HORIZONTAL
      gravity = Gravity.CENTER_VERTICAL
    }
    renderFolderChips()

    return HorizontalScrollView(this).apply {
      isHorizontalScrollBarEnabled = false
      addView(folderRow)
    }
  }

  private fun renderFolderChips() {
    folderRow.removeAllViews()
    val visibleFolders = folders.filter {
      folderSearchQuery.isBlank() || it.name.contains(folderSearchQuery, ignoreCase = true)
    }

    if (visibleFolders.isEmpty()) {
      folderRow.addView(
        text(
          value = if (folders.isEmpty()) "보관함 불러오는 중" else "검색 결과 없음",
          sizeSp = 18f,
          color = COLOR_GRAY_600,
          weight = Typeface.BOLD,
        ),
      )
      return
    }

    visibleFolders.forEachIndexed { index, folder ->
      val chip = text(
        value = folder.name,
        sizeSp = 20f,
        color = if (folder.id == selectedFolder?.id) COLOR_BLUE_500 else COLOR_GRAY_600,
        weight = Typeface.BOLD,
      ).apply {
        minWidth = dp(100f)
        gravity = Gravity.CENTER
        setPadding(dp(18f), dp(10f), dp(18f), dp(10f))
        background = roundedDrawable(
          color = if (folder.id == selectedFolder?.id) Color.rgb(238, 247, 255) else Color.WHITE,
          radius = dp(28f),
          strokeColor = if (folder.id == selectedFolder?.id) COLOR_BLUE_500 else COLOR_NEUTRAL_100,
          strokeWidth = dp(1f),
        )
        setOnClickListener {
          selectedFolder = folder
          renderFolderChips()
        }
      }
      folderRow.addView(chip)
      if (index != visibleFolders.lastIndex) {
        folderRow.addView(space(widthDp = 10f, heightDp = 1f))
      }
    }
  }

  private fun buildMemoLabel(): View {
    return LinearLayout(this).apply {
      orientation = LinearLayout.HORIZONTAL
      gravity = Gravity.CENTER_VERTICAL

      addView(
        NoteIconView(this@AndroidShareActivity),
        LinearLayout.LayoutParams(dp(24f), dp(24f)),
      )
      addView(space(widthDp = 12f, heightDp = 1f))
      addView(
        text(
          value = "메모",
          sizeSp = 20f,
          color = COLOR_GRAY_900,
          weight = Typeface.BOLD,
        ),
      )
      addView(
        text(
          value = "(선택)",
          sizeSp = 20f,
          color = COLOR_GRAY_600,
          weight = Typeface.BOLD,
        ),
      )
    }
  }

  private fun buildMemoInput(): View {
    memoInput = EditText(this).apply {
      minHeight = dp(80f)
      maxLines = 4
      gravity = Gravity.TOP
      textSize = 18f
      setTextColor(COLOR_GRAY_900)
      setHintTextColor(COLOR_GRAY_600)
      hint = "자료에 대한 정보를 간단하게 메모해보세요."
      imeOptions = EditorInfo.IME_ACTION_DONE
      background = roundedDrawable(COLOR_NEUTRAL_300, dp(10f), 0, 0)
      setPadding(dp(20f), dp(18f), dp(20f), dp(12f))
      addTextChangedListener(
        object : TextWatcher {
          override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
          override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            val length = s?.length ?: 0
            memoCounterView.text = "$length/$MEMO_MAX_LENGTH"
          }

          override fun afterTextChanged(s: Editable?) {
            if ((s?.length ?: 0) <= MEMO_MAX_LENGTH) return
            s?.delete(MEMO_MAX_LENGTH, s.length)
          }
        },
      )
    }
    return memoInput
  }

  private fun buildCounterRow(): View {
    return LinearLayout(this).apply {
      gravity = Gravity.END or Gravity.CENTER_VERTICAL
      memoCounterView = text(
        value = "0/$MEMO_MAX_LENGTH",
        sizeSp = 20f,
        color = COLOR_GRAY_600,
        weight = Typeface.NORMAL,
      )
      addView(memoCounterView)
    }
  }

  private fun loadFolders() {
    saveButton.isEnabled = false
    if (!apiClient.hasRequiredAuth()) {
      Toast.makeText(this, "앱에서 로그인이 필요합니다.", Toast.LENGTH_SHORT).show()
      saveButton.isEnabled = false
      return
    }

    Thread {
      runCatching { apiClient.fetchFolders() }
        .onSuccess { fetchedFolders ->
          runOnUiThread {
            folders = fetchedFolders
            selectedFolder = fetchedFolders.firstOrNull { it.isDefault } ?: fetchedFolders.firstOrNull()
            saveButton.isEnabled = selectedFolder != null
            renderFolderChips()
          }
        }
        .onFailure { error ->
          runOnUiThread {
            Toast.makeText(this, error.userMessage(), Toast.LENGTH_SHORT).show()
            saveButton.isEnabled = false
            renderFolderChips()
          }
        }
    }.start()
  }

  private fun handleSave() {
    val targetFolder = selectedFolder
    if (targetFolder == null) {
      Toast.makeText(this, "보관함을 선택해주세요.", Toast.LENGTH_SHORT).show()
      return
    }
    if (sharedItems.isEmpty()) {
      Toast.makeText(this, "공유 항목을 찾을 수 없습니다.", Toast.LENGTH_SHORT).show()
      return
    }

    saveButton.isEnabled = false
    val memo = memoInput.text?.toString()?.trim().orEmpty()

    Thread {
      runCatching {
        sharedItems.forEach { item ->
          saveSharedItem(item = item, folderId = targetFolder.id, memo = memo)
        }
        dirtyStore.markFolderDirty(targetFolder.id)
      }
        .onSuccess {
          runOnUiThread {
            Toast.makeText(this, "공유 항목이 저장되었습니다.", Toast.LENGTH_SHORT).show()
            saveButton.postDelayed({ finish() }, 450L)
          }
        }
        .onFailure { error ->
          runOnUiThread {
            saveButton.isEnabled = true
            Toast.makeText(this, error.userMessage(), Toast.LENGTH_SHORT).show()
          }
        }
    }.start()
  }

  private fun saveSharedItem(item: SharedItem, folderId: Int, memo: String) {
    when (item) {
      is SharedItem.Link -> apiClient.createLink(folderId, item.url, memo)
      is SharedItem.Note -> apiClient.createText(
        folderId = folderId,
        textContent = mergeSharedTextAndMemo(sharedText = item.text, memo = memo),
      )
      is SharedItem.Image -> apiClient.uploadImage(
        folderId = folderId,
        uri = item.uri,
        fileName = item.displayName,
        mimeType = item.mimeType,
        memo = memo,
      )
      is SharedItem.File -> apiClient.uploadFile(
        folderId = folderId,
        uri = item.uri,
        fileName = item.displayName,
        mimeType = item.mimeType,
        memo = memo,
      )
    }
  }

  private fun mergeSharedTextAndMemo(sharedText: String, memo: String): String {
    val trimmedText = sharedText.trim()
    val trimmedMemo = memo.trim()
    if (trimmedMemo.isEmpty()) return trimmedText
    if (trimmedText.isEmpty()) return trimmedMemo
    return "$trimmedText\n\n$trimmedMemo"
  }

  private fun parseSharedItems(sourceIntent: Intent?): List<SharedItem> {
    if (sourceIntent == null) return emptyList()
    return when (sourceIntent.action) {
      Intent.ACTION_SEND -> parseSingleSharedItem(sourceIntent)
      Intent.ACTION_SEND_MULTIPLE -> parseMultipleSharedItems(sourceIntent)
      else -> emptyList()
    }
  }

  private fun parseSingleSharedItem(sourceIntent: Intent): List<SharedItem> {
    val streamUri = sourceIntent.parcelable<Uri>(Intent.EXTRA_STREAM)
    if (streamUri != null) {
      return listOf(sharedItemFromUri(streamUri, sourceIntent.type))
    }

    val text = sourceIntent.getStringExtra(Intent.EXTRA_TEXT)?.trim().orEmpty()
    if (text.isEmpty()) return emptyList()

    val link = extractUrl(text)
    return if (link != null) {
      listOf(SharedItem.Link(link))
    } else {
      listOf(SharedItem.Note(text))
    }
  }

  private fun parseMultipleSharedItems(sourceIntent: Intent): List<SharedItem> {
    val streamUris = sourceIntent.parcelableArrayList<Uri>(Intent.EXTRA_STREAM).orEmpty()
    val mimeTypes = sourceIntent.getStringArrayExtra(Intent.EXTRA_MIME_TYPES)

    return streamUris.mapIndexed { index, uri ->
      sharedItemFromUri(uri, mimeTypes?.getOrNull(index) ?: sourceIntent.type)
    }
  }

  private fun sharedItemFromUri(uri: Uri, intentMimeType: String?): SharedItem {
    val mimeType = resolveMimeType(uri, intentMimeType)
    val displayName = displayNameForUri(uri)
    val sizeBytes = sizeForUri(uri)

    return if (mimeType?.startsWith("image/") == true) {
      SharedItem.Image(uri, displayName, mimeType, sizeBytes)
    } else {
      SharedItem.File(uri, displayName, mimeType, sizeBytes)
    }
  }

  private fun resolveMimeType(uri: Uri, intentMimeType: String?): String? {
    if (!intentMimeType.isNullOrBlank() && intentMimeType != "*/*") {
      return intentMimeType
    }

    val resolverMimeType = contentResolver.getType(uri)
    if (!resolverMimeType.isNullOrBlank()) {
      return resolverMimeType
    }

    return URLConnection.guessContentTypeFromName(displayNameForUri(uri))
  }

  private fun displayNameForUri(uri: Uri): String {
    contentResolver.query(uri, null, null, null, null)?.use { cursor ->
      val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
      if (index >= 0 && cursor.moveToFirst()) {
        val displayName = cursor.getString(index)
        if (!displayName.isNullOrBlank()) return displayName
      }
    }
    return uri.lastPathSegment?.substringAfterLast('/').orEmpty().ifBlank { "공유 파일" }
  }

  private fun sizeForUri(uri: Uri): Long? {
    contentResolver.query(uri, null, null, null, null)?.use { cursor ->
      val index = cursor.getColumnIndex(OpenableColumns.SIZE)
      if (index >= 0 && cursor.moveToFirst() && !cursor.isNull(index)) {
        return cursor.getLong(index)
      }
    }
    return null
  }

  private fun extractUrl(text: String): String? {
    val match = Regex("""https?://\S+""").find(text) ?: return null
    return match.value.trimEnd('.', ',', ')', ']', '}')
  }

  private fun sharedItemsSummary(): String {
    if (sharedItems.isEmpty()) return "공유 항목 없음"
    val counts = sharedItems.groupingBy { it.label }.eachCount()
    return counts.entries.joinToString(", ") { (label, count) -> "$label ${count}개" }
  }

  private fun Throwable.userMessage(): String {
    return when (this) {
      is AndroidShareApiError -> message ?: "공유 항목 저장에 실패했습니다."
      else -> message?.takeIf { it.isNotBlank() } ?: "공유 항목 저장에 실패했습니다."
    }
  }

  private fun text(value: String, sizeSp: Float, color: Int, weight: Int): TextView {
    return TextView(this).apply {
      text = value
      textSize = sizeSp
      setTextColor(color)
      typeface = Typeface.create(Typeface.DEFAULT, weight)
      includeFontPadding = true
    }
  }

  private fun roundedDrawable(
    color: Int,
    radius: Int,
    strokeColor: Int,
    strokeWidth: Int,
  ): GradientDrawable {
    return GradientDrawable().apply {
      shape = GradientDrawable.RECTANGLE
      setColor(color)
      cornerRadius = radius.toFloat()
      if (strokeWidth > 0) {
        setStroke(strokeWidth, strokeColor)
      }
    }
  }

  private fun roundedTopDrawable(color: Int, radius: Int): GradientDrawable {
    return GradientDrawable().apply {
      shape = GradientDrawable.RECTANGLE
      setColor(color)
      cornerRadii = floatArrayOf(
        radius.toFloat(),
        radius.toFloat(),
        radius.toFloat(),
        radius.toFloat(),
        0f,
        0f,
        0f,
        0f,
      )
    }
  }

  private fun space(heightDp: Float): View = space(widthDp = 1f, heightDp = heightDp)

  private fun space(widthDp: Float, heightDp: Float): View {
    return View(this).apply {
      layoutParams = LinearLayout.LayoutParams(dp(widthDp), dp(heightDp))
    }
  }

  private fun dp(value: Float): Int {
    return (value * resources.displayMetrics.density + 0.5f).toInt()
  }

  private inline fun <reified T : Parcelable> Intent.parcelable(key: String): T? {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      getParcelableExtra(key, T::class.java)
    } else {
      @Suppress("DEPRECATION")
      getParcelableExtra(key) as? T
    }
  }

  private inline fun <reified T : Parcelable> Intent.parcelableArrayList(key: String): ArrayList<T>? {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      getParcelableArrayListExtra(key, T::class.java)
    } else {
      @Suppress("DEPRECATION")
      getParcelableArrayListExtra(key)
    }
  }

  private sealed class SharedItem(val label: String) {
    data class Link(val url: String) : SharedItem("링크")
    data class Note(val text: String) : SharedItem("메모")
    data class Image(
      val uri: Uri,
      val displayName: String,
      val mimeType: String?,
      val sizeBytes: Long?,
    ) : SharedItem("이미지")

    data class File(
      val uri: Uri,
      val displayName: String,
      val mimeType: String?,
      val sizeBytes: Long?,
    ) : SharedItem("파일")
  }

  private class SearchIconView(context: Context) : View(context) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
      color = COLOR_GRAY_900
      style = Paint.Style.STROKE
      strokeWidth = dp(3f)
      strokeCap = Paint.Cap.ROUND
    }

    override fun onDraw(canvas: Canvas) {
      super.onDraw(canvas)
      val radius = width * 0.28f
      val center = width * 0.43f
      canvas.drawCircle(center, center, radius, paint)
      canvas.drawLine(width * 0.64f, height * 0.64f, width * 0.86f, height * 0.86f, paint)
    }

    private fun dp(value: Float): Float {
      return value * resources.displayMetrics.density
    }
  }

  private class ClearIconView(context: Context) : View(context) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
      color = COLOR_GRAY_600
      style = Paint.Style.STROKE
      strokeWidth = dp(2.5f)
      strokeCap = Paint.Cap.ROUND
    }

    override fun onDraw(canvas: Canvas) {
      super.onDraw(canvas)
      val centerX = width / 2f
      val centerY = height / 2f
      val radius = width * 0.36f
      val offset = width * 0.14f
      canvas.drawCircle(centerX, centerY, radius, paint)
      canvas.drawLine(centerX - offset, centerY - offset, centerX + offset, centerY + offset, paint)
      canvas.drawLine(centerX + offset, centerY - offset, centerX - offset, centerY + offset, paint)
    }

    private fun dp(value: Float): Float {
      return value * resources.displayMetrics.density
    }
  }

  private class NoteIconView(context: Context) : View(context) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
      color = COLOR_BLUE_500
      style = Paint.Style.STROKE
      strokeWidth = dp(2.4f)
      strokeCap = Paint.Cap.ROUND
      strokeJoin = Paint.Join.ROUND
    }

    override fun onDraw(canvas: Canvas) {
      super.onDraw(canvas)
      val left = width * 0.16f
      val top = height * 0.12f
      val right = width * 0.84f
      val bottom = height * 0.88f
      canvas.drawRoundRect(left, top, right, bottom, dp(3f), dp(3f), paint)
      canvas.drawLine(width * 0.32f, height * 0.36f, width * 0.68f, height * 0.36f, paint)
      canvas.drawLine(width * 0.32f, height * 0.56f, width * 0.62f, height * 0.56f, paint)
    }

    private fun dp(value: Float): Float {
      return value * resources.displayMetrics.density
    }
  }
}

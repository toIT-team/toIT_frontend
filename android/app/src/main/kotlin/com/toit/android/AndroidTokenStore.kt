package com.toit.android

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class AndroidTokenStore(private val context: Context) {
  companion object {
    private const val PREFS_NAME = "toit_auth_bridge"
    private const val KEY_ALIAS = "toit_auth_bridge_key"
    private const val TRANSFORMATION = "AES/GCM/NoPadding"
    private const val GCM_TAG_BITS = 128

    private const val ACCESS_TOKEN = "access_token"
    private const val REFRESH_TOKEN = "refresh_token"
    private const val USER_ID = "user_id"
    private const val API_BASE_URL = "api_base_url"
  }

  private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

  fun save(
    accessToken: String,
    refreshToken: String,
    userId: Int,
    baseUrl: String,
  ) {
    prefs.edit()
      .putString(ACCESS_TOKEN, encrypt(accessToken))
      .putString(REFRESH_TOKEN, encrypt(refreshToken))
      .putInt(USER_ID, userId)
      .putString(API_BASE_URL, baseUrl)
      .apply()
  }

  fun readAccessToken(): String? = decrypt(prefs.getString(ACCESS_TOKEN, null))

  fun readRefreshToken(): String? = decrypt(prefs.getString(REFRESH_TOKEN, null))

  fun readUserId(): Int = prefs.getInt(USER_ID, 0)

  fun readBaseUrl(): String? = prefs.getString(API_BASE_URL, null)

  fun clear() {
    prefs.edit().clear().apply()
  }

  private fun encrypt(value: String): String {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return value

    val cipher = Cipher.getInstance(TRANSFORMATION)
    cipher.init(Cipher.ENCRYPT_MODE, getOrCreateSecretKey())
    val encrypted = cipher.doFinal(value.toByteArray(Charsets.UTF_8))
    val payload = cipher.iv + encrypted
    return Base64.encodeToString(payload, Base64.NO_WRAP)
  }

  private fun decrypt(value: String?): String? {
    if (value.isNullOrEmpty()) return null
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return value

    return try {
      val payload = Base64.decode(value, Base64.NO_WRAP)
      if (payload.size <= 12) return null
      val iv = payload.copyOfRange(0, 12)
      val encrypted = payload.copyOfRange(12, payload.size)
      val cipher = Cipher.getInstance(TRANSFORMATION)
      cipher.init(
        Cipher.DECRYPT_MODE,
        getOrCreateSecretKey(),
        GCMParameterSpec(GCM_TAG_BITS, iv),
      )
      String(cipher.doFinal(encrypted), Charsets.UTF_8)
    } catch (_: Exception) {
      null
    }
  }

  private fun getOrCreateSecretKey(): SecretKey {
    val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
    (keyStore.getEntry(KEY_ALIAS, null) as? KeyStore.SecretKeyEntry)?.let {
      return it.secretKey
    }

    val generator = KeyGenerator.getInstance(
      KeyProperties.KEY_ALGORITHM_AES,
      "AndroidKeyStore",
    )
    val spec = KeyGenParameterSpec.Builder(
      KEY_ALIAS,
      KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
    )
      .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
      .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
      .setRandomizedEncryptionRequired(true)
      .build()
    generator.init(spec)
    return generator.generateKey()
  }
}

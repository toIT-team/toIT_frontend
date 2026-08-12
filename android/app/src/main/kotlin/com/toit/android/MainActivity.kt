package com.toit.android

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

open class MainActivity : FlutterActivity() {
  private companion object {
    const val TOKEN_CHANNEL = "com.toit/token"
    const val LAUNCH_INFO_CHANNEL = "com.toit/launch_info"
    const val IS_SHARE_LAUNCH_METHOD = "isShareLaunch"
    const val FINISH_SHARE_LAUNCH_METHOD = "finishShareLaunch"
    const val DIRTY_CHANNEL = "com.toit/external_save_dirty"
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      TOKEN_CHANNEL,
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        "syncToken" -> {
          val accessToken = call.argument<String>("accessToken")
          val refreshToken = call.argument<String>("refreshToken")
          val userId = (call.argument<Number>("userId"))?.toInt()
          val baseUrl = call.argument<String>("baseUrl")
          if (
            accessToken.isNullOrEmpty() ||
            refreshToken.isNullOrEmpty() ||
            userId == null ||
            baseUrl.isNullOrEmpty()
          ) {
            result.error("INVALID_ARGS", "accessToken, refreshToken, userId, baseUrl 필수", null)
            return@setMethodCallHandler
          }
          AndroidTokenStore(this).save(
            accessToken = accessToken,
            refreshToken = refreshToken,
            userId = userId,
            baseUrl = baseUrl,
          )
          result.success(true)
        }
        "clearToken" -> {
          AndroidTokenStore(this).clear()
          result.success(true)
        }
        else -> result.notImplemented()
      }
    }
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      LAUNCH_INFO_CHANNEL,
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        IS_SHARE_LAUNCH_METHOD -> {
          result.success(isShareIntent(intent))
        }
        FINISH_SHARE_LAUNCH_METHOD -> {
          if (isShareIntent(intent)) {
            finish()
          }
          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      DIRTY_CHANNEL,
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        "markFolderDirty" -> {
          val folderId = (call.argument<Number>("folderId"))?.toInt()
          if (folderId == null || folderId <= 0) {
            result.error("INVALID_ARGS", "folderId 필수", null)
            return@setMethodCallHandler
          }
          AndroidExternalSaveDirtyStore(this).markFolderDirty(folderId)
          result.success(null)
        }
        "consumeDirtyFolderIds" -> {
          result.success(AndroidExternalSaveDirtyStore(this).consumeDirtyFolderIds())
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun isShareIntent(targetIntent: Intent?): Boolean {
    val action = targetIntent?.action ?: return false
    val isSendAction = action == Intent.ACTION_SEND ||
      action == Intent.ACTION_SEND_MULTIPLE
    if (!isSendAction) return false

    return targetIntent.hasExtra(Intent.EXTRA_STREAM) ||
      targetIntent.hasExtra(Intent.EXTRA_TEXT)
  }

}

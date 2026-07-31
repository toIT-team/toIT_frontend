package com.toit.android

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

open class MainActivity : FlutterActivity() {
  private companion object {
    const val LAUNCH_INFO_CHANNEL = "com.toit/launch_info"
    const val IS_SHARE_LAUNCH_METHOD = "isShareLaunch"
    const val FINISH_SHARE_LAUNCH_METHOD = "finishShareLaunch"
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      LAUNCH_INFO_CHANNEL,
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        IS_SHARE_LAUNCH_METHOD -> {
          result.success(isShareIntent(intent))
        }
        FINISH_SHARE_LAUNCH_METHOD -> {
          if (this is AndroidShareActivity) {
            finish()
          }
          result.success(null)
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

package com.example.poj_todo

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private companion object {
    const val LAUNCH_INFO_CHANNEL = "com.example.pojTodo/launch_info"
    const val IS_SHARE_LAUNCH_METHOD = "isShareLaunch"
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LAUNCH_INFO_CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          IS_SHARE_LAUNCH_METHOD -> {
            result.success(isShareIntent(intent))
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

    return targetIntent.hasExtra(Intent.EXTRA_STREAM)
  }
}

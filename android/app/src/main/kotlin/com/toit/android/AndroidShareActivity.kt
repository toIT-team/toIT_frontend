package com.toit.android

import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode

class AndroidShareActivity : MainActivity() {
  override fun getInitialRoute(): String = "/android-share"

  override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent
}

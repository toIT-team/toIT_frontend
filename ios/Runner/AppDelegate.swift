import Flutter
import UIKit
// TODO(FCM-비활성화): 테스트 중 임시 주석
// import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // TODO(FCM-비활성화): 테스트 중 임시 주석
    // UNUserNotificationCenter.current().delegate = self
    // application.registerForRemoteNotifications()

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }

  func didInitializeImplicitFlutterEngine(
    _ engineBridge: FlutterImplicitEngineBridge
  ) {
    GeneratedPluginRegistrant.register(
      with: engineBridge.pluginRegistry
    )
    // SceneDelegate에서 FlutterViewController 캐스팅에 의존하면
    // 등록이 누락될 수 있으므로 엔진 준비 시 여기서 등록한다
    TokenBridge.register(
      with: engineBridge.applicationRegistrar.messenger()
    )
  }
}

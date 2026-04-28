import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    guard let url = URLContexts.first?.url else { return }
    handleDeepLink(url)
  }

  private func handleDeepLink(_ url: URL) {
    guard let window = self.window,
          let controller = window.rootViewController
            as? FlutterViewController
    else { return }

    let channel = FlutterMethodChannel(
      name: "com.toit/deeplink",
      binaryMessenger: controller.binaryMessenger
    )
    channel.invokeMethod("onDeepLink", arguments: url.absoluteString)
  }
}

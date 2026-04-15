import Flutter
import Foundation

/// Flutter MethodChannel을 통해 토큰·설정 값을
/// App Group UserDefaults에 저장하여 Share Extension과 공유한다.
final class TokenBridge {
  static let channelName = "com.example.pojTodo/token"

  private static let suiteName = "group.com.example.pojTodo.share"
  static let keyAccessToken = "access_token"
  static let keyUserId = "user_id"
  static let keyBaseUrl = "api_base_url"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "syncToken":
        guard let args = call.arguments as? [String: Any],
              let accessToken = args["accessToken"] as? String,
              let userId = args["userId"] as? Int,
              let baseUrl = args["baseUrl"] as? String
        else {
          result(
            FlutterError(
              code: "INVALID_ARGS",
              message: "accessToken, userId, baseUrl 필수",
              details: nil
            )
          )
          return
        }
        save(
          accessToken: accessToken,
          userId: userId,
          baseUrl: baseUrl
        )
        result(true)

      case "clearToken":
        clear()
        result(true)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func save(
    accessToken: String,
    userId: Int,
    baseUrl: String
  ) {
    guard let defaults = UserDefaults(suiteName: suiteName)
    else {
      NSLog("[TokenBridge] UserDefaults 생성 실패 - suiteName: \(suiteName)")
      return
    }
    defaults.set(accessToken, forKey: keyAccessToken)
    defaults.set(userId, forKey: keyUserId)
    defaults.set(baseUrl, forKey: keyBaseUrl)
    defaults.synchronize()

    let verify = defaults.string(forKey: keyAccessToken)
    NSLog("[TokenBridge] 저장 완료 - token: \(verify != nil ? "있음" : "nil"), userId: \(userId), baseUrl: \(baseUrl)")
  }

  private static func clear() {
    guard let defaults = UserDefaults(suiteName: suiteName)
    else { return }
    defaults.removeObject(forKey: keyAccessToken)
    defaults.removeObject(forKey: keyUserId)
    defaults.removeObject(forKey: keyBaseUrl)
    defaults.synchronize()
  }
}

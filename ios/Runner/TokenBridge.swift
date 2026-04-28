import Flutter
import Foundation

/// Flutter MethodChannel → App Group `UserDefaults`로 Share Extension과 공유.
final class TokenBridge {
  static let channelName = "com.toit/token"

  static let keyAccessToken = "access_token"
  static let keyUserId = "user_id"
  static let keyBaseUrl = "api_base_url"

  /// MethodChannel이 Dart int를 `NSNumber` 등으로 넘기는 경우가 있어 `Int?`로 통일
  private static func intFromMethodChannel(
    value: Any?
  ) -> Int? {
    if let n = value as? Int { return n }
    if let n = value as? NSNumber { return n.intValue }
    return nil
  }

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
              let baseUrl = args["baseUrl"] as? String
        else {
          result(
            FlutterError(
              code: "INVALID_ARGS",
              message: "accessToken, baseUrl 필수",
              details: nil
            )
          )
          return
        }
        guard let userId = intFromMethodChannel(value: args["userId"])
        else {
          result(
            FlutterError(
              code: "INVALID_ARGS",
              message: "userId 필수(숫자)",
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
    guard let defaults = AppGroupConfig.sharedUserDefaults
    else {
      NSLog(
        "[TokenBridge] App Group UserDefaults nil — AppGroupId: "
        + "\(String(describing: AppGroupConfig.identifier))"
      )
      return
    }
    defaults.set(accessToken, forKey: keyAccessToken)
    defaults.set(userId, forKey: keyUserId)
    defaults.set(baseUrl, forKey: keyBaseUrl)
    defaults.synchronize()
    let verify = defaults.string(forKey: keyAccessToken)
    NSLog(
      "[TokenBridge] 저장 token: \(verify != nil ? "있음" : "nil"),"
      + " userId: \(userId), baseUrl: \(baseUrl)"
    )
  }

  private static func clear() {
    guard let defaults = AppGroupConfig.sharedUserDefaults
    else { return }
    defaults.removeObject(forKey: keyAccessToken)
    defaults.removeObject(forKey: keyUserId)
    defaults.removeObject(forKey: keyBaseUrl)
    defaults.synchronize()
  }
}

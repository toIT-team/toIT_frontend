import Flutter
import Foundation

/// Flutter MethodChannel → App Group `UserDefaults`로 Share Extension과 공유.
final class TokenBridge {
  static let channelName = "com.toit/token"

  static let keyAccessToken = "access_token"
  static let keyRefreshToken = "refresh_token"
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
              let refreshToken = args["refreshToken"] as? String,
              let baseUrl = args["baseUrl"] as? String
        else {
          result(
            FlutterError(
              code: "INVALID_ARGS",
              message: "accessToken, refreshToken, baseUrl 필수",
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
          refreshToken: refreshToken,
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
    refreshToken: String,
    userId: Int,
    baseUrl: String
  ) {
    guard let defaults = AppGroupConfig.sharedUserDefaults
    else {
      // NSLog(
      //   "[TokenBridge] App Group UserDefaults nil — AppGroupId: "
      //   + "\(String(describing: AppGroupConfig.identifier))"
      // )
      return
    }
    guard SharedKeychainTokenStore.saveAccessToken(accessToken)
            && SharedKeychainTokenStore.saveRefreshToken(refreshToken)
    else { return }

    defaults.removeObject(forKey: keyAccessToken)
    defaults.removeObject(forKey: keyRefreshToken)
    defaults.set(userId, forKey: keyUserId)
    defaults.set(baseUrl, forKey: keyBaseUrl)
    defaults.synchronize()
    // let verify = defaults.string(forKey: keyAccessToken)
    // NSLog(
    //   "[TokenBridge] 저장 token: \(verify != nil ? "있음" : "nil"),"
    //   + " userId: \(userId), baseUrl: \(baseUrl)"
    // )
  }

  private static func clear() {
    guard let defaults = AppGroupConfig.sharedUserDefaults
    else { return }
    SharedKeychainTokenStore.deleteTokens()
    defaults.removeObject(forKey: keyAccessToken)
    defaults.removeObject(forKey: keyRefreshToken)
    defaults.removeObject(forKey: keyUserId)
    defaults.removeObject(forKey: keyBaseUrl)
    defaults.synchronize()
  }
}

final class ExternalSaveDirtyBridge {
  static let channelName = "com.toit/external_save_dirty"

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
      case "markFolderDirty":
        guard let args = call.arguments as? [String: Any],
              let folderId = intFromMethodChannel(value: args["folderId"]),
              folderId > 0
        else {
          result(
            FlutterError(
              code: "INVALID_ARGS",
              message: "folderId 필수",
              details: nil
            )
          )
          return
        }
        ExternalSaveDirtyStore.markFolderDirty(folderId)
        result(nil)

      case "consumeDirtyFolderIds":
        result(ExternalSaveDirtyStore.consumeDirtyFolderIds())

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

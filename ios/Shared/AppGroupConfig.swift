import Foundation
import Security

/// App Group ID와 공유 `UserDefaults`에 대한 단일 진입점.
/// - `Info.plist` 키 `AppGroupId` — 빌드 시 `$(CUSTOM_GROUP_ID)`로
///   치환되며, 각 타깃(Runner, Share Extension)에 동일
///   `CUSTOM_GROUP_ID`가 있어야 한다
/// - 권한: `*.entitlements`의
///   `com.apple.security.application-groups`와 내용이 같아야 한다
enum AppGroupConfig {
  private static let appGroupIdInfoPlistKey = "AppGroupId"

  /// 빌드에 반영된 App Group id. 미치환/미설정이면 `nil`
  static var identifier: String? {
    guard
      let raw = Bundle.main.object(
        forInfoDictionaryKey: appGroupIdInfoPlistKey
      ) as? String
    else { return nil }
    let trimmed = raw.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    if trimmed.isEmpty { return nil }
    if trimmed.hasPrefix("$(") { return nil }
    return trimmed
  }

  /// App Group `UserDefaults`. `identifier`를 만들 수 없으면 `nil`
  static var sharedUserDefaults: UserDefaults? {
    guard let id = identifier else { return nil }
    return UserDefaults(suiteName: id)
  }
}

/// Runner와 Share Extension이 함께 읽는 Keychain 저장소.
/// access token은 App Group UserDefaults 대신 이 access group에만 저장한다.
enum SharedKeychainTokenStore {
  private static let accessGroup = "86MPU972PJ.com.toit.ios.shared"
  private static let service = "com.toit.ios.auth"
  private static let accessTokenAccount = "access_token"

  static func saveAccessToken(_ token: String) -> Bool {
    guard let data = token.data(using: .utf8) else { return false }

    var query = baseQuery(account: accessTokenAccount)
    query[kSecValueData as String] = data
    query[kSecAttrAccessible as String] =
      kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

    let status = SecItemAdd(query as CFDictionary, nil)
    if status == errSecSuccess { return true }
    if status != errSecDuplicateItem { return false }

    let attributes = [
      kSecValueData as String: data,
      kSecAttrAccessible as String:
        kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    ] as [String: Any]

    let updateStatus = SecItemUpdate(
      baseQuery(account: accessTokenAccount) as CFDictionary,
      attributes as CFDictionary
    )
    return updateStatus == errSecSuccess
  }

  static func readAccessToken() -> String? {
    var query = baseQuery(account: accessTokenAccount)
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    query[kSecReturnData as String] = true

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard
      status == errSecSuccess,
      let data = item as? Data,
      let token = String(data: data, encoding: .utf8),
      !token.isEmpty
    else { return nil }

    return token
  }

  static func deleteAccessToken() {
    SecItemDelete(baseQuery(account: accessTokenAccount) as CFDictionary)
  }

  private static func baseQuery(account: String) -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecAttrAccessGroup as String: accessGroup,
    ]
  }
}

import Foundation

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

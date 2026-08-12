import Foundation

/// Share Extension 전용 경량 API 클라이언트.
/// App Group `UserDefaults`에서 인증 정보를 읽는다.
final class ShareApiClient {
  private var accessToken: String
  private var refreshToken: String?
  private let baseUrl: String
  let userId: Int

  init?(fromAppGroup: Void = ()) {
    guard
      let defaults = AppGroupConfig.sharedUserDefaults
    else {
      // NSLog(
      //   "[ShareApiClient] App Group UserDefaults nil — AppGroupId: "
      //   + "\(String(describing: AppGroupConfig.identifier))"
      // )
      return nil
    }

    let token = Self.resolveAccessToken(from: defaults)
    let refreshToken = Self.resolveRefreshToken(from: defaults)
    let url = defaults.string(forKey: "api_base_url")
    let uid = defaults.integer(forKey: "user_id")

    guard
      let token, let url,
      !token.isEmpty, !url.isEmpty
    else { return nil }

    self.accessToken = token
    self.refreshToken = refreshToken
    self.baseUrl = url
    self.userId = uid
  }

  private static func resolveAccessToken(
    from defaults: UserDefaults
  ) -> String? {
    if let token = SharedKeychainTokenStore.readAccessToken(),
       !token.isEmpty {
      return token
    }

    guard
      let legacyToken = defaults.string(forKey: "access_token"),
      !legacyToken.isEmpty
    else { return nil }

    if SharedKeychainTokenStore.saveAccessToken(legacyToken) {
      defaults.removeObject(forKey: "access_token")
      defaults.synchronize()
    }

    return legacyToken
  }

  private static func resolveRefreshToken(
    from defaults: UserDefaults
  ) -> String? {
    if let token = SharedKeychainTokenStore.readRefreshToken(),
       !token.isEmpty {
      return token
    }

    guard
      let legacyToken = defaults.string(forKey: "refresh_token"),
      !legacyToken.isEmpty
    else { return nil }

    if SharedKeychainTokenStore.saveRefreshToken(legacyToken) {
      defaults.removeObject(forKey: "refresh_token")
      defaults.synchronize()
    }

    return legacyToken
  }

  // MARK: - Folder List

  func fetchFolders() async throws -> [ShareFolder] {
    let today = Self.todayString()
    var components = URLComponents(
      string: "\(baseUrl)/page/home"
    )!
    components.queryItems = [
      URLQueryItem(name: "usersId", value: "\(userId)"),
      URLQueryItem(name: "todayDate", value: today),
    ]

    let (data, response) = try await request(
      url: components.url!,
      method: "GET"
    )
    try validateResponse(response)

    guard let json = try JSONSerialization.jsonObject(
      with: data
    ) as? [String: Any],
      let foldersJson = json["folders"] as? [[String: Any]]
    else { return [] }

    return foldersJson.compactMap { ShareFolder(json: $0) }
  }

  // MARK: - Upload Image

  func uploadImage(
    data imageData: Data,
    fileName: String,
    folderId: Int,
    textContent: String
  ) async throws {
    var components = URLComponents(
      string: "\(baseUrl)/attachments/images"
    )!
    components.queryItems = [
      URLQueryItem(name: "usersId", value: "\(userId)"),
      URLQueryItem(
        name: "foldersIdList", value: "\(folderId)"
      ),
      URLQueryItem(name: "textContent", value: textContent),
    ]

    try await uploadMultipart(
      url: components.url!,
      fieldName: "image",
      fileData: imageData,
      fileName: fileName,
      mimeType: "image/jpeg"
    )
  }

  // MARK: - Upload File

  func uploadFile(
    data fileData: Data,
    fileName: String,
    folderId: Int,
    textContent: String
  ) async throws {
    var components = URLComponents(
      string: "\(baseUrl)/attachments/files"
    )!
    components.queryItems = [
      URLQueryItem(name: "usersId", value: "\(userId)"),
      URLQueryItem(
        name: "foldersIdList", value: "\(folderId)"
      ),
      URLQueryItem(name: "textContent", value: textContent),
    ]

    try await uploadMultipart(
      url: components.url!,
      fieldName: "file",
      fileData: fileData,
      fileName: fileName,
      mimeType: "application/octet-stream"
    )
  }

  // MARK: - Link

  struct LinkPreview {
    let linksName: String
    let textContent: String
    let linksThumbnail: String

    init(json: [String: Any]) {
      linksName = json["linksName"] as? String ?? ""
      textContent = json["textContent"] as? String ?? ""
      linksThumbnail = json["linksThumbnail"] as? String ?? ""
    }
  }

  func fetchLinkPreview(linksUrl: String) async throws -> LinkPreview {
    let url = URL(string: "\(baseUrl)/links/preview")!
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue(
      "application/json",
      forHTTPHeaderField: "Content-Type"
    )
    req.timeoutInterval = 15

    req.httpBody = try JSONSerialization.data(
      withJSONObject: ["linksUrl": linksUrl]
    )

    let (data, response) = try await dataForAuthorizedRequest {
      req
    }
    try validateResponse(response)

    guard let json = try JSONSerialization.jsonObject(
      with: data
    ) as? [String: Any] else {
      return LinkPreview(json: [:])
    }
    return LinkPreview(json: json)
  }

  func createLink(
    linksUrl: String,
    folderId: Int,
    linksName: String,
    textContent: String,
    linksThumbnail: String
  ) async throws {
    let url = URL(string: "\(baseUrl)/links")!
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue(
      "application/json",
      forHTTPHeaderField: "Content-Type"
    )
    req.timeoutInterval = 15

    var body: [String: Any] = [
      "foldersIdList": [folderId],
      "linksUrl": linksUrl,
    ]
    if !textContent.isEmpty {
      body["textContent"] = textContent
    }
    if !linksName.isEmpty {
      body["linksName"] = linksName
    }
    if !linksThumbnail.isEmpty {
      body["linksThumbnail"] = linksThumbnail
    }
    req.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (_, response) = try await dataForAuthorizedRequest {
      req
    }
    try validateResponse(response)
  }

  // MARK: - Private Helpers

  private func request(
    url: URL,
    method: String
  ) async throws -> (Data, URLResponse) {
    var req = URLRequest(url: url)
    req.httpMethod = method
    req.timeoutInterval = 15
    return try await dataForAuthorizedRequest {
      req
    }
  }

  private func dataForAuthorizedRequest(
    _ makeRequest: () throws -> URLRequest
  ) async throws -> (Data, URLResponse) {
    var req = try makeRequest()
    applyAuthorization(to: &req)

    let (data, response) = try await URLSession.shared.data(for: req)
    guard isUnauthorized(response) else {
      return (data, response)
    }

    guard try await reissueAccessToken() else {
      return (data, response)
    }

    var retryReq = try makeRequest()
    applyAuthorization(to: &retryReq)
    return try await URLSession.shared.data(for: retryReq)
  }

  private func applyAuthorization(to req: inout URLRequest) {
    req.setValue(
      "Bearer \(accessToken)",
      forHTTPHeaderField: "Authorization"
    )
  }

  private func uploadMultipart(
    url: URL,
    fieldName: String,
    fileData: Data,
    fileName: String,
    mimeType: String
  ) async throws {
    let boundary = UUID().uuidString

    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue(
      "multipart/form-data; boundary=\(boundary)",
      forHTTPHeaderField: "Content-Type"
    )
    req.timeoutInterval = 60

    var body = Data()
    let crlf = "\r\n"
    body.append(
      "--\(boundary)\(crlf)"
        .data(using: .utf8)!
    )
    body.append(
      ("Content-Disposition: form-data; " +
        "name=\"\(fieldName)\"; " +
        "filename=\"\(fileName)\"\(crlf)")
        .data(using: .utf8)!
    )
    body.append(
      "Content-Type: \(mimeType)\(crlf)\(crlf)"
        .data(using: .utf8)!
    )
    body.append(fileData)
    body.append(
      "\(crlf)--\(boundary)--\(crlf)"
        .data(using: .utf8)!
    )
    req.httpBody = body

    let (_, response) = try await dataForAuthorizedRequest {
      req
    }
    try validateResponse(response)
  }

  private func reissueAccessToken() async throws -> Bool {
    guard let refreshToken, !refreshToken.isEmpty else {
      return false
    }

    let url = URL(string: "\(baseUrl)/api/auth/reissue")!
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue(
      "application/json",
      forHTTPHeaderField: "Content-Type"
    )
    req.timeoutInterval = 15
    req.httpBody = try JSONSerialization.data(
      withJSONObject: ["refreshToken": refreshToken]
    )

    let (data, response) = try await URLSession.shared.data(for: req)
    guard let http = response as? HTTPURLResponse else {
      throw ShareApiError.invalidResponse
    }
    guard (200...299).contains(http.statusCode) else {
      if http.statusCode == 401 {
        throw ShareApiError.unauthorized
      }
      throw ShareApiError.serverError(http.statusCode)
    }

    guard
      let json = try JSONSerialization.jsonObject(with: data)
        as? [String: Any],
      let newAccessToken = json["accessToken"] as? String,
      !newAccessToken.isEmpty
    else {
      throw ShareApiError.invalidResponse
    }

    let newRefreshToken = json["refreshToken"] as? String
    self.accessToken = newAccessToken
    if let newRefreshToken, !newRefreshToken.isEmpty {
      self.refreshToken = newRefreshToken
      _ = SharedKeychainTokenStore.saveRefreshToken(newRefreshToken)
    }
    _ = SharedKeychainTokenStore.saveAccessToken(newAccessToken)
    return true
  }

  private func validateResponse(
    _ response: URLResponse
  ) throws {
    guard let http = response as? HTTPURLResponse else {
      throw ShareApiError.invalidResponse
    }
    switch http.statusCode {
    case 200...299:
      return
    case 401:
      throw ShareApiError.unauthorized
    default:
      throw ShareApiError.serverError(http.statusCode)
    }
  }

  private func isUnauthorized(_ response: URLResponse) -> Bool {
    guard let http = response as? HTTPURLResponse else {
      return false
    }
    return http.statusCode == 401
  }

  private static func todayString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: Date())
  }
}

enum ShareApiError: LocalizedError {
  case unauthorized
  case invalidResponse
  case serverError(Int)

  var errorDescription: String? {
    switch self {
    case .unauthorized:
      return "인증이 만료되었습니다. 앱에서 다시 로그인해주세요."
    case .invalidResponse:
      return "서버 응답을 처리할 수 없습니다."
    case .serverError(let code):
      return "서버 오류가 발생했습니다. (\(code))"
    }
  }
}

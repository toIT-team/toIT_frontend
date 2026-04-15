import Foundation

/// Share Extension 전용 경량 API 클라이언트.
/// App Group UserDefaults에서 인증 정보를 읽어 URLSession으로 호출한다.
final class ShareApiClient {
  private let accessToken: String
  private let baseUrl: String
  let userId: Int

  private static let suiteName =
    "group.com.example.pojTodo.share"

  init?(fromAppGroup: Void = ()) {
    guard let defaults = UserDefaults(
      suiteName: ShareApiClient.suiteName
    ) else {
      NSLog("[ShareApiClient] UserDefaults 생성 실패 - suiteName: \(ShareApiClient.suiteName)")
      return nil
    }

    let token = defaults.string(forKey: "access_token")
    let url = defaults.string(forKey: "api_base_url")
    let uid = defaults.integer(forKey: "user_id")

    NSLog("[ShareApiClient] App Group 읽기 결과 - token: \(token != nil ? "있음(\(token!.prefix(10))...)" : "nil"), url: \(url ?? "nil"), userId: \(uid)")

    guard let token, let url,
          !token.isEmpty, !url.isEmpty
    else { return nil }

    self.accessToken = token
    self.baseUrl = url
    self.userId = uid
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

  // MARK: - Private Helpers

  private func request(
    url: URL,
    method: String
  ) async throws -> (Data, URLResponse) {
    var req = URLRequest(url: url)
    req.httpMethod = method
    req.setValue(
      "Bearer \(accessToken)",
      forHTTPHeaderField: "Authorization"
    )
    req.timeoutInterval = 15
    return try await URLSession.shared.data(for: req)
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
      "Bearer \(accessToken)",
      forHTTPHeaderField: "Authorization"
    )
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

    let (_, response) = try await URLSession.shared.data(
      for: req
    )
    try validateResponse(response)
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

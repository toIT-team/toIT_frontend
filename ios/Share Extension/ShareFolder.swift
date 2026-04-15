import Foundation

struct ShareFolder {
  let foldersId: Int
  let title: String
  let isDefault: Bool

  init(foldersId: Int, title: String, isDefault: Bool = false) {
    self.foldersId = foldersId
    self.title = title
    self.isDefault = isDefault
  }

  init?(json: [String: Any]) {
    guard let id = json["foldersId"] as? Int,
          let name = json["name"] as? String
    else { return nil }
    self.foldersId = id
    self.title = name
    self.isDefault = json["isDefault"] as? Bool ?? false
  }
}

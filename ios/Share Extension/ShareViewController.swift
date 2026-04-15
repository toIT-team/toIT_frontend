import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
  private enum Constants {
    static let maxMemoLength = 1000
    static let chipHorizontalPadding: CGFloat = 18
    static let chipVerticalPadding: CGFloat = 8
    static let bottomPadding: CGFloat = 20
  }

  private var apiClient: ShareApiClient?
  private var allFolders: [ShareFolder] = []
  private var displayedFolders: [ShareFolder] = []
  private var selectedFolder: ShareFolder?
  private var sharedItemUrls: [URL] = []
  private var isImage = true
  private var isSaving = false

  // MARK: - UI Elements

  private let cardView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = .white
    v.layer.cornerRadius = 24
    v.layer.maskedCorners = [
      .layerMinXMinYCorner, .layerMaxXMinYCorner
    ]
    v.clipsToBounds = true
    return v
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "보관함"
    label.textColor = UIColor(
      red: 0.13, green: 0.13, blue: 0.13, alpha: 1
    )
    label.font = .systemFont(ofSize: 22, weight: .bold)
    return label
  }()

  private lazy var saveButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("저장", for: .normal)
    button.titleLabel?.font = .systemFont(
      ofSize: 16, weight: .semibold
    )
    button.setTitleColor(
      UIColor(
        red: 0.22, green: 0.61, blue: 0.98, alpha: 1
      ),
      for: .normal
    )
    button.addTarget(
      self, action: #selector(saveTapped),
      for: .touchUpInside
    )
    return button
  }()

  private let loadingIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(
      style: .medium
    )
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    return indicator
  }()

  private let searchContainerView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = UIColor(
      red: 0.96, green: 0.97, blue: 0.98, alpha: 1
    )
    v.layer.cornerRadius = 14
    return v
  }()

  private let searchIconView: UIImageView = {
    let iv = UIImageView(
      image: UIImage(systemName: "magnifyingglass")
    )
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.tintColor = UIColor(
      red: 0.13, green: 0.13, blue: 0.13, alpha: 1
    )
    return iv
  }()

  private lazy var searchTextField: UITextField = {
    let tf = UITextField()
    tf.translatesAutoresizingMaskIntoConstraints = false
    tf.placeholder = "보관함 입력"
    tf.font = .systemFont(ofSize: 16, weight: .semibold)
    tf.textColor = UIColor(
      red: 0.13, green: 0.13, blue: 0.13, alpha: 1
    )
    tf.clearButtonMode = .whileEditing
    tf.addTarget(
      self, action: #selector(searchTextChanged),
      for: .editingChanged
    )
    return tf
  }()

  private lazy var chipsCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 10
    layout.sectionInset = .zero
    let cv = UICollectionView(
      frame: .zero, collectionViewLayout: layout
    )
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.backgroundColor = .clear
    cv.showsHorizontalScrollIndicator = false
    cv.dataSource = self
    cv.delegate = self
    cv.register(
      FolderChipCell.self,
      forCellWithReuseIdentifier: FolderChipCell.reuseId
    )
    return cv
  }()

  private let memoHeaderIconView: UIImageView = {
    let iv = UIImageView(
      image: UIImage(systemName: "doc.text")
    )
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.tintColor = UIColor(
      red: 0.22, green: 0.61, blue: 0.98, alpha: 1
    )
    return iv
  }()

  private let memoHeaderLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "메모(선택)"
    label.textColor = UIColor(
      red: 0.13, green: 0.13, blue: 0.13, alpha: 1
    )
    label.font = .systemFont(ofSize: 18, weight: .bold)
    return label
  }()

  private let memoContainerView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = UIColor(
      red: 0.96, green: 0.97, blue: 0.98, alpha: 1
    )
    v.layer.cornerRadius = 12
    return v
  }()

  private lazy var memoTextView: UITextView = {
    let tv = UITextView()
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.font = .systemFont(ofSize: 16, weight: .medium)
    tv.textColor = UIColor(
      red: 0.13, green: 0.13, blue: 0.13, alpha: 1
    )
    tv.backgroundColor = .clear
    tv.textContainerInset = .zero
    tv.textContainer.lineFragmentPadding = 0
    tv.delegate = self
    return tv
  }()

  private let memoPlaceholderLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "자료에 대한 정보를 간단하게 메모해보세요."
    label.textColor = UIColor(
      red: 0.50, green: 0.51, blue: 0.61, alpha: 1
    )
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  private let memoCounterLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "0/1000"
    label.textColor = UIColor(
      red: 0.50, green: 0.51, blue: 0.61, alpha: 1
    )
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.textAlignment = .right
    return label
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
    loadSharedItems()
    initApiAndFetchFolders()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    clearSystemBackgrounds()
  }

  private func clearSystemBackgrounds() {
    var current: UIView? = view.superview
    while let sv = current {
      sv.backgroundColor = .clear
      current = sv.superview
    }
  }

  // MARK: - API Init & Folder Fetch

  private func initApiAndFetchFolders() {
    guard let client = ShareApiClient() else {
      showError("로그인 정보가 없습니다.\n앱에서 로그인 후 다시 시도해주세요.")
      return
    }
    self.apiClient = client
    loadingIndicator.startAnimating()
    saveButton.isHidden = true

    Task {
      do {
        let folders = try await client.fetchFolders()
        await MainActor.run {
          self.allFolders = folders
          self.displayedFolders = folders
          self.selectedFolder = folders.first(
            where: { $0.isDefault }
          ) ?? folders.first
          self.chipsCollectionView.reloadData()
          self.loadingIndicator.stopAnimating()
          self.saveButton.isHidden = false
        }
      } catch let error as ShareApiError {
        await MainActor.run {
          self.loadingIndicator.stopAnimating()
          self.showError(error.errorDescription ?? "오류 발생")
        }
      } catch {
        await MainActor.run {
          self.loadingIndicator.stopAnimating()
          self.showError("보관함을 불러올 수 없습니다.")
        }
      }
    }
  }

  // MARK: - Shared Item Loading

  private func loadSharedItems() {
    guard let item = extensionContext?.inputItems.first
            as? NSExtensionItem,
          let attachments = item.attachments
    else { return }

    let group = DispatchGroup()

    for provider in attachments {
      if provider.hasItemConformingToTypeIdentifier(
        UTType.image.identifier
      ) {
        isImage = true
        group.enter()
        provider.loadItem(
          forTypeIdentifier: UTType.image.identifier
        ) { [weak self] item, _ in
          defer { group.leave() }
          if let url = item as? URL {
            self?.sharedItemUrls.append(url)
          }
        }
      } else if provider.hasItemConformingToTypeIdentifier(
        UTType.data.identifier
      ) {
        isImage = false
        group.enter()
        provider.loadItem(
          forTypeIdentifier: UTType.data.identifier
        ) { [weak self] item, _ in
          defer { group.leave() }
          if let url = item as? URL {
            self?.sharedItemUrls.append(url)
          }
        }
      }
    }
  }

  // MARK: - Layout

  private func setupLayout() {
    view.backgroundColor = .clear

    let dimTap = UITapGestureRecognizer(
      target: self, action: #selector(cancelTapped)
    )
    dimTap.delegate = self
    view.addGestureRecognizer(dimTap)

    view.addSubview(cardView)

    let headerStack = UIStackView(
      arrangedSubviews: [titleLabel, saveButton]
    )
    headerStack.translatesAutoresizingMaskIntoConstraints
      = false
    headerStack.axis = .horizontal
    headerStack.alignment = .center

    cardView.addSubview(headerStack)
    cardView.addSubview(loadingIndicator)
    cardView.addSubview(searchContainerView)
    searchContainerView.addSubview(searchIconView)
    searchContainerView.addSubview(searchTextField)
    cardView.addSubview(chipsCollectionView)
    cardView.addSubview(memoHeaderIconView)
    cardView.addSubview(memoHeaderLabel)
    cardView.addSubview(memoContainerView)
    memoContainerView.addSubview(memoTextView)
    memoContainerView.addSubview(memoPlaceholderLabel)
    cardView.addSubview(memoCounterLabel)

    let safeBottom = view.safeAreaLayoutGuide.bottomAnchor

    NSLayoutConstraint.activate([
      cardView.leadingAnchor.constraint(
        equalTo: view.leadingAnchor
      ),
      cardView.trailingAnchor.constraint(
        equalTo: view.trailingAnchor
      ),
      cardView.bottomAnchor.constraint(
        equalTo: view.bottomAnchor
      ),

      headerStack.topAnchor.constraint(
        equalTo: cardView.topAnchor, constant: 16
      ),
      headerStack.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor, constant: 20
      ),
      headerStack.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor, constant: -20
      ),

      loadingIndicator.centerYAnchor.constraint(
        equalTo: headerStack.centerYAnchor
      ),
      loadingIndicator.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor, constant: -20
      ),

      searchContainerView.topAnchor.constraint(
        equalTo: headerStack.bottomAnchor, constant: 18
      ),
      searchContainerView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor, constant: 20
      ),
      searchContainerView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor, constant: -20
      ),
      searchContainerView.heightAnchor.constraint(
        equalToConstant: 56
      ),

      searchIconView.leadingAnchor.constraint(
        equalTo: searchContainerView.leadingAnchor,
        constant: 14
      ),
      searchIconView.centerYAnchor.constraint(
        equalTo: searchContainerView.centerYAnchor
      ),
      searchIconView.widthAnchor.constraint(
        equalToConstant: 24
      ),
      searchIconView.heightAnchor.constraint(
        equalToConstant: 24
      ),

      searchTextField.leadingAnchor.constraint(
        equalTo: searchIconView.trailingAnchor, constant: 10
      ),
      searchTextField.trailingAnchor.constraint(
        equalTo: searchContainerView.trailingAnchor,
        constant: -12
      ),
      searchTextField.centerYAnchor.constraint(
        equalTo: searchContainerView.centerYAnchor
      ),

      chipsCollectionView.topAnchor.constraint(
        equalTo: searchContainerView.bottomAnchor,
        constant: 12
      ),
      chipsCollectionView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor, constant: 20
      ),
      chipsCollectionView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor, constant: -20
      ),
      chipsCollectionView.heightAnchor.constraint(
        equalToConstant: 44
      ),

      memoHeaderIconView.topAnchor.constraint(
        equalTo: chipsCollectionView.bottomAnchor,
        constant: 22
      ),
      memoHeaderIconView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor, constant: 20
      ),
      memoHeaderIconView.widthAnchor.constraint(
        equalToConstant: 20
      ),
      memoHeaderIconView.heightAnchor.constraint(
        equalToConstant: 20
      ),

      memoHeaderLabel.leadingAnchor.constraint(
        equalTo: memoHeaderIconView.trailingAnchor,
        constant: 8
      ),
      memoHeaderLabel.centerYAnchor.constraint(
        equalTo: memoHeaderIconView.centerYAnchor
      ),

      memoContainerView.topAnchor.constraint(
        equalTo: memoHeaderIconView.bottomAnchor,
        constant: 10
      ),
      memoContainerView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor, constant: 20
      ),
      memoContainerView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor, constant: -20
      ),
      memoContainerView.heightAnchor.constraint(
        equalToConstant: 120
      ),

      memoTextView.topAnchor.constraint(
        equalTo: memoContainerView.topAnchor, constant: 13
      ),
      memoTextView.leadingAnchor.constraint(
        equalTo: memoContainerView.leadingAnchor,
        constant: 13
      ),
      memoTextView.trailingAnchor.constraint(
        equalTo: memoContainerView.trailingAnchor,
        constant: -13
      ),
      memoTextView.bottomAnchor.constraint(
        equalTo: memoContainerView.bottomAnchor,
        constant: -13
      ),

      memoPlaceholderLabel.topAnchor.constraint(
        equalTo: memoContainerView.topAnchor, constant: 13
      ),
      memoPlaceholderLabel.leadingAnchor.constraint(
        equalTo: memoContainerView.leadingAnchor,
        constant: 13
      ),
      memoPlaceholderLabel.trailingAnchor.constraint(
        equalTo: memoContainerView.trailingAnchor,
        constant: -13
      ),

      memoCounterLabel.topAnchor.constraint(
        equalTo: memoContainerView.bottomAnchor,
        constant: 10
      ),
      memoCounterLabel.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor, constant: -20
      ),
      memoCounterLabel.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor, constant: 20
      ),

      memoCounterLabel.bottomAnchor.constraint(
        equalTo: safeBottom,
        constant: -Constants.bottomPadding
      ),
    ])
  }

  // MARK: - Actions

  @objc
  private func searchTextChanged() {
    let keyword = searchTextField.text?
      .trimmingCharacters(in: .whitespacesAndNewlines)
      ?? ""
    let matched = keyword.isEmpty
      ? allFolders
      : allFolders.filter {
          $0.title.localizedCaseInsensitiveContains(keyword)
        }

    if keyword.isEmpty || !matched.isEmpty {
      displayedFolders = matched
      chipsCollectionView.reloadData()
    }
  }

  @objc
  private func saveTapped() {
    guard !isSaving else { return }
    guard let client = apiClient else {
      showError("로그인 정보가 없습니다.")
      return
    }
    guard let folder = selectedFolder else {
      showError("보관함을 선택해주세요.")
      return
    }
    guard !sharedItemUrls.isEmpty else {
      showError("공유된 파일이 없습니다.")
      return
    }

    isSaving = true
    saveButton.isEnabled = false
    loadingIndicator.startAnimating()

    let memo = memoTextView.text ?? ""
    let urls = sharedItemUrls
    let uploadAsImage = isImage

    Task {
      do {
        for url in urls {
          let data = try Data(contentsOf: url)
          let fileName = url.lastPathComponent

          if uploadAsImage {
            try await client.uploadImage(
              data: data,
              fileName: fileName,
              folderId: folder.foldersId,
              textContent: memo
            )
          } else {
            try await client.uploadFile(
              data: data,
              fileName: fileName,
              folderId: folder.foldersId,
              textContent: memo
            )
          }
        }

        await MainActor.run {
          self.openAppAndComplete(
            folderId: folder.foldersId,
            folderName: folder.title
          )
        }
      } catch {
        await MainActor.run {
          self.isSaving = false
          self.saveButton.isEnabled = true
          self.loadingIndicator.stopAnimating()
          self.showError(
            error.localizedDescription
          )
        }
      }
    }
  }

  @objc
  private func cancelTapped() {
    extensionContext?.cancelRequest(
      withError: NSError(
        domain: "com.example.pojTodo.share",
        code: 0,
        userInfo: nil
      )
    )
  }

  // MARK: - Navigation

  private func openAppAndComplete(
    folderId: Int,
    folderName: String
  ) {
    let tab = isImage ? "images" : "files"
    let encodedName = folderName.addingPercentEncoding(
      withAllowedCharacters: .urlQueryAllowed
    ) ?? folderName

    let urlString = "toit://folder"
      + "?id=\(folderId)"
      + "&name=\(encodedName)"
      + "&tab=\(tab)"

    if let url = URL(string: urlString) {
      var responder: UIResponder? = self
      while let r = responder {
        if let app = r as? UIApplication {
          app.open(url)
          break
        }
        responder = r.next
      }
    }

    extensionContext?.completeRequest(
      returningItems: [], completionHandler: nil
    )
  }

  // MARK: - Error

  private func showError(_ message: String) {
    let alert = UIAlertController(
      title: nil, message: message,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(
      title: "확인", style: .default
    ) { [weak self] _ in
      self?.cancelTapped()
    })
    present(alert, animated: true)
  }
}

// MARK: - UIGestureRecognizerDelegate

extension ShareViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch
  ) -> Bool {
    let location = touch.location(in: view)
    return !cardView.frame.contains(location)
  }
}

// MARK: - UICollectionView DataSource & Delegate

extension ShareViewController:
  UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout
{
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return displayedFolders.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: FolderChipCell.reuseId,
      for: indexPath
    ) as? FolderChipCell else {
      return UICollectionViewCell()
    }

    let folder = displayedFolders[indexPath.item]
    cell.configure(
      title: folder.title,
      isSelected: folder.foldersId
        == selectedFolder?.foldersId
    )
    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    selectedFolder = displayedFolders[indexPath.item]
    collectionView.reloadData()
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let title = displayedFolders[indexPath.item].title
    let attrs: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(
        ofSize: 16, weight: .semibold
      ),
    ]
    let width = title.size(withAttributes: attrs).width
    return CGSize(
      width: width + (Constants.chipHorizontalPadding * 2),
      height: Constants.chipVerticalPadding * 2 + 22
    )
  }
}

// MARK: - UITextView Delegate

extension ShareViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    if textView.text.count > Constants.maxMemoLength {
      textView.text = String(
        textView.text.prefix(Constants.maxMemoLength)
      )
    }
    memoPlaceholderLabel.isHidden = !textView.text.isEmpty
    memoCounterLabel.text =
      "\(textView.text.count)/\(Constants.maxMemoLength)"
  }
}

// MARK: - FolderChipCell

private final class FolderChipCell: UICollectionViewCell {
  static let reuseId = "FolderChipCell"

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.layer.cornerRadius = 22
    contentView.layer.borderWidth = 1
    contentView.addSubview(titleLabel)

    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor, constant: 18
      ),
      titleLabel.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor, constant: -18
      ),
      titleLabel.topAnchor.constraint(
        equalTo: contentView.topAnchor, constant: 8
      ),
      titleLabel.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor, constant: -8
      ),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(title: String, isSelected: Bool) {
    titleLabel.text = title
    if isSelected {
      contentView.backgroundColor = UIColor(
        red: 0.22, green: 0.61, blue: 0.98, alpha: 0.14
      )
      contentView.layer.borderColor = UIColor(
        red: 0.22, green: 0.61, blue: 0.98, alpha: 1
      ).cgColor
      titleLabel.textColor = UIColor(
        red: 0.22, green: 0.61, blue: 0.98, alpha: 1
      )
    } else {
      contentView.backgroundColor = .white
      contentView.layer.borderColor = UIColor(
        red: 0.87, green: 0.87, blue: 0.87, alpha: 1
      ).cgColor
      titleLabel.textColor = UIColor(
        red: 0.50, green: 0.51, blue: 0.61, alpha: 1
      )
    }
  }
}

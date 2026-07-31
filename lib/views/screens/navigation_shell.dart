import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../controllers/calendar_controller.dart';
import '../../controllers/home_controller.dart';
import '../../core/constants/folder_tab_index.dart';
import '../../core/deep_link/toit_deep_link_opener.dart';
import '../../core/utils/upload_validation_utils.dart';
import '../../providers/pending_uploads_provider.dart';
import '../../models/home/folder_item.dart';
import '../../repositories/home_repository.dart';
import '../widgets/common/app_snack_bar.dart';
import '../widgets/common/custom_bottom_nav_bar.dart';
import '../widgets/common/share_save_bottom_sheet.dart';
import '../widgets/common/upload_progress_banner.dart';
import 'folder_detail_screen.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'save_link_screen.dart';
import 'save_note_screen.dart';
import 'save_file_screen.dart';
import 'save_image_screen.dart';
import 'event_form_screen.dart';

/// 현재 선택된 탭 인덱스 Provider
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

/// FCM 등에서 설정 후 [NavigationShell]이 소비하는 대기 딥링크 URL
final pendingDeepLinkUrlProvider = StateProvider<String?>((ref) => null);

/// 네비게이션 쉘 (하단 네비바 + 화면 전환 관리)
class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({super.key});

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  static const _deepLinkChannel = MethodChannel('com.toit/deeplink');

  StreamSubscription<List<SharedMediaFile>>? _shareMediaSubscription;
  bool _isShareSheetVisible = false;
  bool _isInitialShareChecked = false;

  @override
  void initState() {
    super.initState();
    _deepLinkChannel.setMethodCallHandler(_handleDeepLink);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consumePendingDeepLinkIfAny();
      _bindShareReceiver();
      ref.read(pendingUploadsProvider.notifier).restoreFromDb();
    });
  }

  @override
  void dispose() {
    _deepLinkChannel.setMethodCallHandler(null);
    _shareMediaSubscription?.cancel();
    super.dispose();
  }

  Future<dynamic> _handleDeepLink(MethodCall call) async {
    if (call.method != 'onDeepLink') return;
    final urlString = call.arguments as String?;
    if (urlString == null) return;
    await _openDeepLinkFromString(urlString);
  }

  /// FCM이 먼저 도착한 뒤 쉘이 붙는 경우 초기 1회 소비
  void _consumePendingDeepLinkIfAny() {
    final pending = ref.read(pendingDeepLinkUrlProvider);
    if (pending == null) return;
    ref.read(pendingDeepLinkUrlProvider.notifier).state = null;
    unawaited(_openDeepLinkFromString(pending));
  }

  Future<void> _openDeepLinkFromString(String urlString) async {
    await ToitDeepLinkOpener.open(ref, context, urlString);
  }

  void _bindShareReceiver() {
    _shareMediaSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (mediaFiles) => _handleSharedMedia(mediaFiles),
          onError: (_) {},
        );
    _checkInitialSharedMedia();
  }

  Future<void> _checkInitialSharedMedia() async {
    if (_isInitialShareChecked) return;
    _isInitialShareChecked = true;
    final mediaFiles = await ReceiveSharingIntent.instance.getInitialMedia();
    await _handleSharedMedia(mediaFiles);
  }

  Future<void> _handleSharedMedia(List<SharedMediaFile> mediaFiles) async {
    if (!mounted || _isShareSheetVisible || mediaFiles.isEmpty) return;

    final sharedItems = mediaFiles
        .map(_toSharedItem)
        .whereType<_SharedItem>()
        .toList();

    if (sharedItems.isEmpty) return;

    _isShareSheetVisible = true;
    try {
      final folders = await _ensureFolderList();
      if (!mounted) return;

      if (folders.isEmpty) {
        _showSnackBar('보관함이 없어 공유 항목을 저장할 수 없습니다.');
        return;
      }

      await showShareSaveBottomSheet(
        context,
        folders: folders,
        initialSelectedFolder: folders.where((f) => f.isDefault).firstOrNull,
        onSave: (selectedFolder, memo) async {
          await _saveSharedItems(
            items: sharedItems,
            selectedFolder: selectedFolder,
            memo: memo,
          );
        },
        errorMessageBuilder: _sharedSaveErrorMessage,
      );
    } finally {
      _isShareSheetVisible = false;
      ReceiveSharingIntent.instance.reset();
    }
  }

  Future<List<FolderItem>> _ensureFolderList() async {
    var state = ref.read(homeProvider);
    if (state.folders.isNotEmpty) return state.folders;

    await ref.read(homeProvider.notifier).refresh();
    state = ref.read(homeProvider);
    return state.folders;
  }

  Future<void> _saveSharedItems({
    required List<_SharedItem> items,
    required FolderItem selectedFolder,
    required String memo,
  }) async {
    final repository = ref.read(homeRepositoryProvider);

    for (final item in items) {
      await _saveSharedItem(
        repository: repository,
        item: item,
        selectedFolder: selectedFolder,
        memo: memo,
      );
    }

    await ref.read(homeProvider.notifier).refresh();
    ref.invalidate(pageItemsProvider(selectedFolder.foldersId));
    _showSnackBar('공유 항목이 저장되었습니다.');
  }

  Future<void> _saveSharedItem({
    required HomeRepository repository,
    required _SharedItem item,
    required FolderItem selectedFolder,
    required String memo,
  }) async {
    switch (item.type) {
      case _SharedItemType.link:
        await repository.createLink(
          foldersIdList: [selectedFolder.foldersId],
          linksUrl: item.value,
          textContent: memo,
        );
      case _SharedItemType.note:
        await repository.createText(
          foldersIdList: [selectedFolder.foldersId],
          textContent: _mergeSharedTextAndMemo(
            sharedText: item.value,
            memo: memo,
          ),
        );
      case _SharedItemType.attachment:
        await _saveSharedAttachment(
          repository: repository,
          item: item,
          selectedFolder: selectedFolder,
          memo: memo,
        );
    }
  }

  Future<void> _saveSharedAttachment({
    required HomeRepository repository,
    required _SharedItem item,
    required FolderItem selectedFolder,
    required String memo,
  }) async {
    final fileBytes = await _readSharedFileBytes(item.value);
    final fileName = _extractFileName(item.value);
    final validateMessage = item.isImage
        ? validateImageSectionUpload(
            fileName: fileName,
            fileSizeBytes: fileBytes.length,
          )
        : validateFileSectionUpload(
            fileName: fileName,
            fileSizeBytes: fileBytes.length,
          );
    if (validateMessage != null) {
      throw _SharedSaveException(validateMessage);
    }

    if (item.isImage) {
      await repository.createImage(
        foldersIdList: [selectedFolder.foldersId],
        textContent: memo,
        imageBytes: fileBytes,
        fileName: fileName,
      );
    } else {
      await repository.createFile(
        foldersIdList: [selectedFolder.foldersId],
        textContent: memo,
        fileBytes: fileBytes,
        fileName: fileName,
      );
    }
  }

  Future<List<int>> _readSharedFileBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const _SharedSaveException('공유된 파일을 찾을 수 없습니다.');
    }

    final fileBytes = await file.readAsBytes();
    if (fileBytes.isEmpty) {
      throw const _SharedSaveException('공유된 파일을 읽을 수 없습니다.');
    }
    return fileBytes;
  }

  String _sharedSaveErrorMessage(Object error) {
    if (error is _SharedSaveException) {
      return error.message;
    }
    if (error is DioException) {
      return _sharedSaveDioErrorMessage(error);
    }
    return '공유 항목 저장에 실패했습니다.';
  }

  String _sharedSaveDioErrorMessage(DioException error) {
    if (error.response?.statusCode == 401) {
      return '인증이 만료되었습니다. 앱에서 다시 로그인해주세요.';
    }
    return '공유 항목 저장 중 오류가 발생했습니다.';
  }

  _SharedItem? _toSharedItem(SharedMediaFile mediaFile) {
    final rawValue = mediaFile.path.trim();
    if (rawValue.isEmpty) return null;

    final sharedLink = _extractSharedLink(rawValue);
    if (mediaFile.type == SharedMediaType.url ||
        mediaFile.type == SharedMediaType.text) {
      if (sharedLink != null) {
        return _SharedItem.link(sharedLink);
      }
      return _SharedItem.note(rawValue);
    }

    if (sharedLink != null && _looksLikeUrlOnly(rawValue)) {
      return _SharedItem.link(sharedLink);
    }

    final normalizedPath = _normalizeFilePath(rawValue);
    if (normalizedPath.trim().isEmpty) return null;
    return _SharedItem.attachment(
      path: normalizedPath,
      isImage:
          mediaFile.type == SharedMediaType.image ||
          _isImagePath(normalizedPath),
    );
  }

  String _normalizeFilePath(String rawPath) {
    if (rawPath.startsWith('file://')) {
      return Uri.parse(rawPath).toFilePath();
    }
    return rawPath;
  }

  bool _isImagePath(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.webp') ||
        lowerPath.endsWith('.gif') ||
        lowerPath.endsWith('.heic') ||
        lowerPath.endsWith('.heif');
  }

  String _extractFileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isEmpty ? 'shared_image.jpg' : parts.last;
  }

  String? _extractSharedLink(String text) {
    final trimmed = text.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return trimmed;
    }

    final match = RegExp(r'https?://[^\s]+').firstMatch(trimmed);
    return match?.group(0);
  }

  bool _looksLikeUrlOnly(String text) {
    final trimmed = text.trim();
    final link = _extractSharedLink(trimmed);
    return link != null && link == trimmed;
  }

  String _mergeSharedTextAndMemo({
    required String sharedText,
    required String memo,
  }) {
    final trimmedText = sharedText.trim();
    final trimmedMemo = memo.trim();
    if (trimmedMemo.isEmpty) return trimmedText;
    if (trimmedText.isEmpty) return trimmedMemo;
    return '$trimmedText\n\n$trimmedMemo';
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    showAppSnackBar(context, message);
  }

  /// 저장 완료 후 저장된 보관함의 해당 탭으로 이동시킨다.
  void _openFolderTab(FolderItem folder, FolderTab tab) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => FolderDetailScreen(
          foldersId: folder.foldersId,
          folderName: folder.title,
          initialTab: tab,
        ),
      ),
    );
  }

  /// 저장 화면을 띄우고, 저장된 보관함이 반환되면 해당 탭으로 이동시킨다.
  void _pushSaveScreen(Widget screen, FolderTab tab) {
    Navigator.of(context)
        .push(CupertinoPageRoute<FolderItem?>(builder: (_) => screen))
        .then((savedFolder) {
          if (savedFolder == null || !mounted) return;
          _openFolderTab(savedFolder, tab);
        });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingDeepLinkUrlProvider, (previous, next) {
      if (next == null) return;
      final toOpen = next;
      ref.read(pendingDeepLinkUrlProvider.notifier).state = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_openDeepLinkFromString(toOpen));
      });
    });

    final currentIndex = ref.watch(currentTabIndexProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: currentIndex,
              children: const [HomeScreen(), CalendarScreen()],
            ),
          ),
          // 업로드 배너는 네비바 위로 떠야 하므로 bottomInset으로 비켜 둔다.
          const Positioned.fill(child: UploadProgressBanner(bottomInset: 84)),
          // Stack에 non-positioned Align만 두면 기본 topStart에 붙어
          // '하단'이 아닌 화면 위쪽에 뜬다. 반드시 bottom 고정.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                if (index == 0) {
                  ref.read(homeProvider.notifier).refresh();
                }
                ref.read(currentTabIndexProvider.notifier).state = index;
              },
              onAddMenuTap: (menuIndex) {
                switch (menuIndex) {
                  case 0:
                    _pushSaveScreen(const SaveLinkScreen(), FolderTab.links);
                    break;
                  case 1:
                    _pushSaveScreen(const SaveNoteScreen(), FolderTab.notes);
                    break;
                  case 2:
                    _pushSaveScreen(const SaveFileScreen(), FolderTab.files);
                    break;
                  case 3:
                    _pushSaveScreen(const SaveImageScreen(), FolderTab.images);
                    break;
                  case 4:
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => const EventFormScreen(),
                          ),
                        )
                        .then((result) {
                          if (result != null) {
                            if (result.isCreate == true) {
                              ref
                                  .read(calendarProvider.notifier)
                                  .revealCreatedEvent(result.event);
                            }
                            ref.read(currentTabIndexProvider.notifier).state =
                                1;
                          }
                        });
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _SharedItemType { attachment, link, note }

class _SharedItem {
  final _SharedItemType type;
  final String value;
  final bool isImage;

  const _SharedItem._({
    required this.type,
    required this.value,
    this.isImage = false,
  });

  const _SharedItem.attachment({required String path, required bool isImage})
    : this._(type: _SharedItemType.attachment, value: path, isImage: isImage);

  const _SharedItem.link(String url)
    : this._(type: _SharedItemType.link, value: url);

  const _SharedItem.note(String text)
    : this._(type: _SharedItemType.note, value: text);
}

class _SharedSaveException implements Exception {
  final String message;

  const _SharedSaveException(this.message);
}

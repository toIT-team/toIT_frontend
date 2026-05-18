import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../controllers/home_controller.dart';
import '../../core/deep_link/toit_deep_link_opener.dart';
import '../../models/pending_image_upload.dart';
import '../../providers/pending_uploads_provider.dart';
import '../../models/home/folder_item.dart';
import '../../repositories/home_repository.dart';
import '../widgets/common/custom_bottom_nav_bar.dart';
import '../widgets/common/share_save_bottom_sheet.dart';
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
  static const _deepLinkChannel = MethodChannel('com.example.pojTodo/deeplink');

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

    final sharedImagePaths = mediaFiles
        .map((file) => _normalizeFilePath(file.path))
        .where(_isImagePath)
        .toList();

    if (sharedImagePaths.isEmpty) return;

    _isShareSheetVisible = true;
    try {
      final folders = await _ensureFolderList();
      if (!mounted) return;

      if (folders.isEmpty) {
        _showSnackBar('보관함이 없어 공유 이미지를 저장할 수 없습니다.');
        return;
      }

      await showShareSaveBottomSheet(
        context,
        folders: folders,
        initialSelectedFolder: folders.where((f) => f.isDefault).firstOrNull,
        onSave: (selectedFolder, memo) async {
          await _saveSharedImages(
            imagePaths: sharedImagePaths,
            selectedFolder: selectedFolder,
            memo: memo,
          );
        },
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

  Future<void> _saveSharedImages({
    required List<String> imagePaths,
    required FolderItem selectedFolder,
    required String memo,
  }) async {
    final repository = ref.read(homeRepositoryProvider);
    int savedCount = 0;
    String? failReason;

    for (final imagePath in imagePaths) {
      final file = File(imagePath);
      if (!await file.exists()) {
        failReason = '이미지 파일을 찾을 수 없습니다.';
        continue;
      }

      List<int> imageBytes;
      try {
        imageBytes = await file.readAsBytes();
      } catch (_) {
        failReason = '이미지 파일을 읽을 수 없습니다.';
        continue;
      }
      if (imageBytes.isEmpty) {
        failReason = '이미지 파일을 읽을 수 없습니다.';
        continue;
      }

      try {
        await repository.createImage(
          foldersIdList: [selectedFolder.foldersId],
          textContent: memo,
          imageBytes: imageBytes,
          fileName: _extractFileName(imagePath),
        );
        savedCount++;
      } on DioException catch (_) {
        failReason = '이미지 저장 중 오류가 발생했습니다.';
      } catch (_) {
        failReason = '이미지 저장에 실패했습니다.';
      }
    }

    if (savedCount <= 0) {
      _showSnackBar(failReason ?? '공유 이미지 저장에 실패했습니다.');
      throw Exception('Failed to save shared images.');
    }

    await ref.read(homeProvider.notifier).refresh();
    ref.invalidate(pageItemsProvider(selectedFolder.foldersId));
    _showSnackBar(
      savedCount == imagePaths.length
          ? '공유 이미지가 저장되었습니다.'
          : '$savedCount장 저장됨. 일부 실패.',
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

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    final pendingUploads = ref.watch(pendingUploadsProvider);
    final isUploading = pendingUploads.any(
      (u) => u.status == PendingUploadStatus.uploading,
    );

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
          if (isUploading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _UploadingBanner(),
            ),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SaveLinkScreen()),
                    );
                    break;
                  case 1:
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SaveNoteScreen()),
                    );
                    break;
                  case 2:
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SaveFileScreen()),
                    );
                    break;
                  case 3:
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SaveImageScreen()),
                    );
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
                            ref.read(currentTabIndexProvider.notifier).state = 1;
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

class _UploadingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          color: const Color(0xFF1A1A1A).withValues(alpha: 0.88),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '이미지 저장 중입니다. 앱을 종료하지 말아주세요.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

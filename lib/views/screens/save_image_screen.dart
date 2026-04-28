import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/system_ui_insets.dart';
import '../../core/widgets/system_safe_area.dart';
import '../../models/home/folder_item.dart';
import '../../core/network/api_client.dart';
import '../../repositories/home_repository.dart';
import '../../services/upload_benchmark_service.dart';
import '../widgets/common/move_to_folder_sheet.dart';
import '../widgets/common/unsaved_exit_dialog.dart';

/// 이미지 저장 화면 (POST /attachments/images API 연동)
class SaveImageScreen extends ConsumerStatefulWidget {
  const SaveImageScreen({super.key, this.initialFolderId});

  final int? initialFolderId;

  @override
  ConsumerState<SaveImageScreen> createState() => _SaveImageScreenState();
}

class _SaveImageScreenState extends ConsumerState<SaveImageScreen> {
  static const int _maxImages = 3;

  final _memoController = TextEditingController();
  int _memoLength = 0;
  final List<XFile> _pickedImages = [];
  FolderItem? _selectedFolder;
  bool _isSaving = false;

  bool get _imageAttached => _pickedImages.isNotEmpty;

  bool get _hasDraft {
    return _imageAttached || _memoController.text.trim().isNotEmpty;
  }

  Future<bool> _handleExitAttempt() async {
    if (_isSaving) return false;
    if (!_hasDraft) return true;
    return showUnsavedExitDialog(context);
  }

  @override
  void initState() {
    super.initState();
    _memoController.addListener(() {
      setState(() => _memoLength = _memoController.text.length);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final folders = ref.read(homeProvider).folders;
      if (folders.isEmpty) return;
      setState(() => _selectedFolder = _resolveInitialFolder(folders));
    });
  }

  FolderItem _resolveInitialFolder(List<FolderItem> folders) {
    final initialId = widget.initialFolderId;
    if (initialId != null) {
      for (final folder in folders) {
        if (folder.foldersId == initialId) return folder;
      }
    }
    return folders.where((f) => f.isDefault).firstOrNull ?? folders.first;
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_imageAttached) {
      _showSnackBar('이미지를 선택해 주세요.');
      return;
    }
    if (_selectedFolder == null) {
      _showSnackBar('보관함을 선택해 주세요.');
      return;
    }

    setState(() => _isSaving = true);
    final repository = ref.read(homeRepositoryProvider);
    final folderId = _selectedFolder!.foldersId;
    final textContent = _memoController.text.trim();
    int successCount = 0;
    String? lastError;
    final sw = Stopwatch()..start();
    final logLines = <String>[];

    // ── 벤치마크: 선택한 이미지들로 N장 × 20회 측정 ──
    final imageData = <({List<int> bytes, String fileName})>[];
    for (final xFile in _pickedImages) {
      imageData.add((bytes: await xFile.readAsBytes(), fileName: xFile.name));
    }
    final benchmarkReport = await UploadBenchmarkService(
      apiClient: ref.read(apiClientProvider),
    ).runImageBatchBenchmark(
      foldersIdList: [folderId],
      images: imageData,
      textContent: textContent,
      iterations: 20,
    );
    // ──────────────────────────────────────────────────

    for (final xFile in _pickedImages) {
      if (!mounted) break;
      List<int> imageBytes;
      final stepSw = Stopwatch()..start();
      try {
        imageBytes = await xFile.readAsBytes();
      } catch (_) {
        lastError = '이미지 데이터를 읽을 수 없습니다.';
        continue;
      }
      final readMs = stepSw.elapsedMilliseconds;
      if (imageBytes.isEmpty) {
        lastError = '이미지 데이터를 읽을 수 없습니다.';
        continue;
      }
      try {
        await repository.createImage(
          foldersIdList: [folderId],
          textContent: textContent,
          imageBytes: imageBytes,
          fileName: xFile.name,
        );
        logLines.add('${xFile.name}  readAsBytes: ${readMs}ms  createImage: ${stepSw.elapsedMilliseconds - readMs}ms');
        successCount++;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        if (statusCode == 413) {
          lastError = '이미지 크기가 서버 제한을 초과했습니다. 더 작은 이미지를 선택해 주세요.';
        } else if (statusCode == 500) {
          lastError = '서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
        } else if (statusCode == 400 &&
            data is Map &&
            data['message'] != null) {
          lastError = data['message'] as String;
        } else {
          lastError = '저장에 실패했습니다. 다시 시도해 주세요.';
        }
      } catch (_) {
        lastError = '저장에 실패했습니다. 다시 시도해 주세요.';
      }
    }

    if (!mounted) return;
    if (successCount > 0) {
      final refreshStart = sw.elapsedMilliseconds;
      final refreshTiming = await ref.read(homeProvider.notifier).refresh();
      final refreshMs = sw.elapsedMilliseconds - refreshStart;
      logLines.add('refresh: ${refreshMs}ms  (fetchHomeData: ${refreshTiming.fetchMs}ms  applyHomeData: ${refreshTiming.applyMs}ms)');
      logLines.add('총 소요: ${sw.elapsedMilliseconds}ms');
      debugPrint('\n$benchmarkReport\n\n[저장 타이밍]\n${logLines.join('\n')}\n');
      ref.invalidate(pageItemsProvider(folderId));
      _showSnackBar(
        successCount == _pickedImages.length
            ? '이미지가 저장되었습니다.'
            : '$successCount장 저장됨. 일부 실패.',
      );
      Navigator.of(context).pop(true);
    } else {
      _showSnackBar(lastError ?? '저장에 실패했습니다. 다시 시도해 주세요.');
    }
    setState(() => _isSaving = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openFolderPicker() {
    showMoveToFolderSheet(
      context,
      ref,
      currentFoldersId: _selectedFolder?.foldersId ?? -1,
      onSelect: (folder) => setState(() => _selectedFolder = folder),
    );
  }

  Future<void> _onAttachImage() async {
    if (_pickedImages.length >= _maxImages) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SystemSafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.gray900,
              ),
              title: const Text(
                '갤러리에서 선택',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.gray900,
              ),
              title: const Text(
                '카메라로 촬영',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picker = ImagePicker();
      if (source == ImageSource.gallery) {
        final remaining = _maxImages - _pickedImages.length;
        final list = await picker.pickMultiImage(
          imageQuality: 85,
          limit: remaining,
        );
        if (list.isEmpty || !mounted) return;
        final toAdd = list.take(remaining).toList();
        setState(() => _pickedImages.addAll(toAdd));
      } else {
        final xFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (xFile != null && mounted && _pickedImages.length < _maxImages) {
          setState(() => _pickedImages.add(xFile));
        }
      }
    } catch (e) {
      if (!mounted) return;
      final isPluginError =
          e.toString().contains('MissingPluginException') ||
          e.toString().contains('LateInitializationError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPluginError
                ? '이미지 선택을 사용하려면 앱을 완전히 종료한 뒤 다시 실행해 주세요.'
                : '이미지를 불러오지 못했습니다.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomeState>(homeProvider, (prev, next) {
      if (_selectedFolder != null) return;
      if (next.folders.isEmpty) return;
      final defaultFolder = _resolveInitialFolder(next.folders);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedFolder == null) {
          setState(() => _selectedFolder = defaultFolder);
        }
      });
    });

    return WillPopScope(
      onWillPop: _handleExitAttempt,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _buildAppBar(),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + systemBottomBarPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildImageSection(),
              const SizedBox(height: 16),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.neutral50,
              ),
              const SizedBox(height: 16),
              _buildFolderSection(),
              const SizedBox(height: 16),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.neutral50,
              ),
              const SizedBox(height: 20),
              _buildMemoSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SystemSafeArea(
      bottom: false,
      child: Container(
        height: 44,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final shouldExit = await _handleExitAttempt();
                if (!shouldExit || !mounted) return;
                Navigator.of(context).pop();
              },
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: AppColors.gray900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '이미지 저장',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 22,
                height: 1.25,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _isSaving ? null : _onSave,
              behavior: HitTestBehavior.opaque,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue500,
                        letterSpacing: -0.025 * 16,
                        height: 1.4,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 첨부 섹션
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppAssets.imageIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.blue500,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '이미지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 18,
                height: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _onAttachImage,
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: _pickedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_outlined,
                        size: 24,
                        color: AppColors.gray600,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '사진 첨부',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray600,
                          letterSpacing: -0.025 * 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  )
                : _buildPickedImagePreview(),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_pickedImages.length}/$_maxImages',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray600,
              letterSpacing: -0.025 * 16,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  /// 선택한 이미지 썸네일을 100x100 고정 크기로 최대 3개 가로 배치
  Widget _buildPickedImagePreview() {
    const double gap = 8;
    const double size = 100;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < _pickedImages.length; i++) ...[
          if (i > 0) const SizedBox(width: gap),
          _buildThumbnail(_pickedImages[i], index: i, size: size),
        ],
        if (_pickedImages.length < _maxImages) ...[
          if (_pickedImages.isNotEmpty) const SizedBox(width: gap),
          _buildAddImageSlot(size: size),
        ],
      ],
    );
  }

  Widget _buildThumbnail(
    XFile xFile, {
    required int index,
    required double size,
  }) {
    final path = xFile.path;
    if (path.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(path), fit: BoxFit.cover),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() => _pickedImages.removeAt(index));
                },
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageSlot({required double size}) {
    return GestureDetector(
      onTap: _onAttachImage,
      child: SizedBox(
        width: size,
        height: size,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.add, size: 28, color: AppColors.gray600),
          ),
        ),
      ),
    );
  }

  /// 보관함 선택 섹션
  Widget _buildFolderSection() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openFolderPicker,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.folder_outlined,
                size: 20,
                color: AppColors.blue500,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedFolder?.title ?? '보관함 선택',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                    letterSpacing: -0.025 * 18,
                    height: 1.4,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.gray600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 메모(선택) 섹션
  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppAssets.noteIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.blue500,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '메모(선택)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 18,
                height: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(13),
          child: TextField(
            controller: _memoController,
            maxLines: null,
            maxLength: 1000,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 16,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText: '자료에 대한 정보를 간단하게 메모해보세요.',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
                letterSpacing: -0.025 * 16,
                height: 1.5,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_memoLength/1000',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray600,
              letterSpacing: -0.025 * 16,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

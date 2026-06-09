import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/system_ui_insets.dart';
import '../../core/utils/upload_validation_utils.dart';
import '../../core/widgets/system_safe_area.dart';
import '../../models/home/folder_item.dart';
import '../../providers/pending_uploads_provider.dart';
import '../widgets/common/app_snack_bar.dart';
import '../widgets/common/move_to_folder_sheet.dart';
import '../widgets/common/unsaved_exit_dialog.dart';

/// 파일 저장 화면 (POST /attachments/files API 연동)
class SaveFileScreen extends ConsumerStatefulWidget {
  const SaveFileScreen({super.key, this.initialFolderId});

  final int? initialFolderId;

  @override
  ConsumerState<SaveFileScreen> createState() => _SaveFileScreenState();
}

class _SaveFileScreenState extends ConsumerState<SaveFileScreen> {
  final _memoController = TextEditingController();
  int _memoLength = 0;
  PlatformFile? _pickedFile;
  FolderItem? _selectedFolder;
  bool _isSaving = false;

  bool get _fileAttached => _pickedFile != null;

  bool get _hasDraft {
    return _fileAttached || _memoController.text.trim().isNotEmpty;
  }

  bool get _canSave {
    return _fileAttached && _selectedFolder != null && !_isSaving;
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
    if (!_fileAttached) {
      return;
    }
    if (_selectedFolder == null) {
      return;
    }
    final selectedFile = _pickedFile!;
    final fileSizeBytes = selectedFile.size;
    final validateMessage = validateFileSectionUpload(
      fileName: selectedFile.name,
      fileSizeBytes: fileSizeBytes,
    );
    if (validateMessage != null) {
      _showSnackBar(validateMessage);
      return;
    }

    List<int>? bytes = selectedFile.bytes != null
        ? _pickedFile!.bytes!
        : (_pickedFile!.path != null
              ? await _readFileBytes(_pickedFile!.path!)
              : null);
    if (bytes == null || bytes.isEmpty) {
      _showSnackBar('파일 데이터를 읽을 수 없습니다.');
      return;
    }

    final fileBytes = bytes;
    final savedFolder = _selectedFolder!;

    setState(() => _isSaving = true);
    if (!mounted) return;
    await ref.read(pendingUploadsProvider.notifier).addFile(
          folderId: savedFolder.foldersId,
          textContent: _memoController.text.trim(),
          fileBytes: fileBytes,
          fileName: selectedFile.name,
        );
    if (!mounted) return;
    Navigator.of(context).pop(savedFolder);
  }

  Future<List<int>?> _readFileBytes(String path) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      return bytes;
    } catch (_) {
      return null;
    }
  }

  void _showSnackBar(String message) {
    showAppSnackBar(context, message);
  }

  void _openFolderPicker() {
    showMoveToFolderSheet(
      context,
      ref,
      currentFoldersId: _selectedFolder?.foldersId ?? -1,
      onSelect: (folder) => setState(() => _selectedFolder = folder),
    );
  }

  Future<void> _onAttachFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty && mounted) {
        final nextFile = result.files.single;
        final validateMessage = validateFileSectionUpload(
          fileName: nextFile.name,
          fileSizeBytes: nextFile.size,
        );
        if (validateMessage != null) {
          _showSnackBar(validateMessage);
          return;
        }
        setState(() => _pickedFile = nextFile);
      }
    } catch (e) {
      if (!mounted) return;
      final isPluginError =
          e.toString().contains('MissingPluginException') ||
          e.toString().contains('LateInitializationError');
      showAppSnackBar(
        context,
        isPluginError
            ? '파일 선택을 사용하려면 앱을 완전히 종료한 뒤 다시 실행해 주세요.'
            : '파일을 불러오지 못했습니다.',
        duration: const Duration(seconds: 4),
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

    return Scaffold(
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
              _buildFileSection(),
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
              '파일 저장',
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
              onTap: _canSave ? _onSave : null,
              behavior: HitTestBehavior.opaque,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _canSave ? AppColors.blue500 : AppColors.gray400,
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

  /// 파일 첨부 섹션
  Widget _buildFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppAssets.fileIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.blue500,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '파일',
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
          onTap: _onAttachFile,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.fileIcon,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray600,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _pickedFile?.name ?? '파일 첨부',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 16,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_pickedFile != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => setState(() => _pickedFile = null),
                    child: const Text(
                      '선택 해제',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.blue500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_fileAttached ? 1 : 0}/1',
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

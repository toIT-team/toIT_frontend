import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/system_ui_insets.dart';
import '../../core/widgets/system_safe_area.dart';
import '../../models/home/folder_item.dart';
import '../../repositories/home_repository.dart';
import '../widgets/common/move_to_folder_sheet.dart';
import '../widgets/common/unsaved_exit_dialog.dart';

/// 노트 저장 화면 (POST /texts API 연동)
class SaveNoteScreen extends ConsumerStatefulWidget {
  const SaveNoteScreen({super.key, this.initialFolderId});

  final int? initialFolderId;

  @override
  ConsumerState<SaveNoteScreen> createState() => _SaveNoteScreenState();
}

class _SaveNoteScreenState extends ConsumerState<SaveNoteScreen> {
  final _noteController = TextEditingController();
  int _textLength = 0;
  FolderItem? _selectedFolder;
  bool _isSaving = false;

  bool get _hasDraft {
    return _noteController.text.trim().isNotEmpty;
  }

  bool get _canSave {
    return _noteController.text.trim().isNotEmpty &&
        _selectedFolder != null &&
        !_isSaving;
  }

  Future<bool> _handleExitAttempt() async {
    if (_isSaving) return false;
    if (!_hasDraft) return true;
    return showUnsavedExitDialog(context);
  }

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() {
      setState(() => _textLength = _noteController.text.length);
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
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final textContent = _noteController.text.trim();
    if (textContent.isEmpty) {
      return;
    }
    if (_selectedFolder == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.createText(
        foldersIdList: [_selectedFolder!.foldersId],
        textContent: textContent,
      );
      await ref.read(homeProvider.notifier).refresh();
      ref.invalidate(pageItemsProvider(_selectedFolder!.foldersId));
      if (!mounted) return;
      _showSnackBar('노트가 저장되었습니다.');
      // 저장된 보관함을 호출자에게 알려, 해당 보관함의 노트 탭으로 이동시킨다.
      Navigator.of(context).pop(_selectedFolder);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('저장에 실패했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

  @override
  Widget build(BuildContext context) {
    // 홈 데이터 로드 후 보관함이 생겼는데 아직 선택 안 했으면 기본 보관함 설정
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
        body: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            systemBottomBarPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildNoteSection(),
              const SizedBox(height: 20),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.neutral50,
              ),
              const SizedBox(height: 16),
              _buildFolderSection(),
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
              '노트 저장',
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

  /// 노트 입력 섹션
  Widget _buildNoteSection() {
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
              '노트',
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
          height: 210,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(13),
          child: TextField(
            controller: _noteController,
            maxLines: null,
            maxLength: 1000,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 16,
              height: 1.4,
            ),
            decoration: const InputDecoration(
              hintText: '내용을 입력해 주세요.',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
                letterSpacing: -0.025 * 16,
                height: 1.4,
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
            '$_textLength/1000',
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
}

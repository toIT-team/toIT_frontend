import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../models/home/folder_item.dart';
import '../../repositories/home_repository.dart';
import '../widgets/common/folder_picker_sheet.dart';

/// 링크 저장 화면 (POST /links API 연동)
class SaveLinkScreen extends ConsumerStatefulWidget {
  const SaveLinkScreen({super.key});

  @override
  ConsumerState<SaveLinkScreen> createState() => _SaveLinkScreenState();
}

class _SaveLinkScreenState extends ConsumerState<SaveLinkScreen> {
  final _linkController = TextEditingController();
  FolderItem? _selectedFolder;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final folders = ref.read(homeProvider).folders;
      if (folders.isEmpty) return;
      final defaultFolder =
          folders.where((f) => f.isDefault).firstOrNull ?? folders.first;
      setState(() => _selectedFolder = defaultFolder);
    });
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final link = _linkController.text.trim();
    if (link.isEmpty) {
      _showSnackBar('링크를 입력해 주세요.');
      return;
    }
    if (_selectedFolder == null) {
      _showSnackBar('보관함을 선택해 주세요.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.createLink(
        foldersIdList: [_selectedFolder!.foldersId],
        linksUrl: link,
      );
      ref.invalidate(pageItemsProvider(_selectedFolder!.foldersId));
      if (!mounted) return;
      _showSnackBar('링크가 저장되었습니다.');
      Navigator.of(context).pop(true);
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
    showFolderPickerSheet(
      context,
      ref,
      selectedFolder: _selectedFolder,
      onSelect: (folder) => setState(() => _selectedFolder = folder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: _buildAppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildLinkSection(),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral50),
            const SizedBox(height: 16),
            _buildFolderSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 44,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
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
              '링크 저장',
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

  /// 링크 입력 섹션
  Widget _buildLinkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppAssets.linkIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.blue500,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '링크',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 18,
                height: 1.25,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: TextField(
            controller: _linkController,
            keyboardType: TextInputType.url,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 16,
            ),
            decoration: const InputDecoration(
              hintText: '링크를 입력해 주세요.',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
                letterSpacing: -0.025 * 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  /// 보관함 선택 섹션
  Widget _buildFolderSection() {
    return GestureDetector(
      onTap: _openFolderPicker,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          const Icon(Icons.folder_outlined, size: 20, color: AppColors.blue500),
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
          const Icon(Icons.chevron_right, size: 20, color: AppColors.gray600),
        ],
      ),
    );
  }
}

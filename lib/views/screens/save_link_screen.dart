import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../models/home/folder_item.dart';
import '../../repositories/home_repository.dart';
import '../widgets/common/folder_picker_sheet.dart';

/// 링크 저장 화면 섹션 간 간격 (px)
const double _kSectionSpacing = 10;

/// 링크 저장 화면 (POST /links/preview → 편집 → POST /links)
class SaveLinkScreen extends ConsumerStatefulWidget {
  const SaveLinkScreen({super.key});

  @override
  ConsumerState<SaveLinkScreen> createState() => _SaveLinkScreenState();
}

class _SaveLinkScreenState extends ConsumerState<SaveLinkScreen> {
  final _linkUrlController = TextEditingController();
  final _linkTitleController = TextEditingController();
  final _linkDescController = TextEditingController();

  FolderItem? _selectedFolder;
  bool _isSaving = false;
  bool _isLoadingPreview = false;

  /// 미리보기를 받아온 URL (이 값과 현재 URL이 다르면 입력 완료 버튼 다시 표시)
  String? _previewUrl;

  /// 미리보기에서 받은 썸네일 URL (저장 시 함께 전송)
  String? _linksThumbnail;

  @override
  void initState() {
    super.initState();
    _linkUrlController.addListener(_onUrlChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final folders = ref.read(homeProvider).folders;
      if (folders.isEmpty) return;
      final defaultFolder =
          folders.where((f) => f.isDefault).firstOrNull ?? folders.first;
      setState(() => _selectedFolder = defaultFolder);
    });
  }

  void _onUrlChanged() {
    if (_trimmedUrl.isEmpty && _previewUrl != null) {
      _linkTitleController.clear();
      _linkDescController.clear();
      _previewUrl = null;
      _linksThumbnail = null;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _linkUrlController.removeListener(_onUrlChanged);
    _linkUrlController.dispose();
    _linkTitleController.dispose();
    _linkDescController.dispose();
    super.dispose();
  }

  String get _trimmedUrl => _linkUrlController.text.trim();

  /// 입력 완료를 한 번이라도 눌렀을 때만 저장 가능 (미리보기 없이 저장 시 null 방지)
  bool get _canSave => _previewUrl != null && !_isSaving;

  /// URL이 비어있지 않고, 아직 미리보기를 안 받았거나 URL이 바뀌었으면 true
  bool get _showInputCompleteButton {
    if (_trimmedUrl.isEmpty) return false;
    if (_previewUrl == null) return true;
    return _previewUrl != _trimmedUrl;
  }

  Future<void> _onInputComplete() async {
    if (_trimmedUrl.isEmpty || _isLoadingPreview) return;
    setState(() => _isLoadingPreview = true);
    try {
      final repository = ref.read(homeRepositoryProvider);
      final preview = await repository.fetchLinkPreview(linksUrl: _trimmedUrl);
      if (!mounted) return;
      _linkTitleController.text = preview.linksName;
      _linkDescController.text = preview.textContent;
      setState(() {
        _previewUrl = _trimmedUrl;
        _linksThumbnail = preview.linksThumbnail.isNotEmpty
            ? preview.linksThumbnail
            : null;
        _isLoadingPreview = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingPreview = false);
      _showSnackBar('링크 정보를 불러오지 못했습니다. 다시 시도해 주세요.');
    }
  }

  void _onClearAll() {
    _linkUrlController.clear();
    _linkTitleController.clear();
    _linkDescController.clear();
    setState(() {
      _previewUrl = null;
      _linksThumbnail = null;
    });
  }

  Future<void> _onSave() async {
    final link = _trimmedUrl;
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
      final title = _linkTitleController.text.trim();
      final desc = _linkDescController.text.trim();
      await repository.createLink(
        foldersIdList: [_selectedFolder!.foldersId],
        linksUrl: link,
        linksName: title.isEmpty ? null : title,
        textContent: desc.isEmpty ? null : desc,
        linksThumbnail: _linksThumbnail,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: _kSectionSpacing),
            _buildLinkSection(),
            if (_previewUrl != null) ...[
              const SizedBox(height: _kSectionSpacing),
              _buildLinkTitleSection(),
              const SizedBox(height: _kSectionSpacing),
              _buildLinkDescSection(),
            ],
            const SizedBox(height: _kSectionSpacing),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral50),
            const SizedBox(height: _kSectionSpacing),
            _buildFolderSection(),
            const SizedBox(height: _kSectionSpacing),
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
            const SizedBox(width: _kSectionSpacing),
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

  /// 링크 입력 섹션 (Figma: 링크 레이블 + 입력 영역 + 입력 완료 버튼 또는 URL + X)
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
            const SizedBox(width: _kSectionSpacing),
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
        const SizedBox(height: _kSectionSpacing),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _linkUrlController,
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
                    isDense: true,
                  ),
                ),
              ),
              if (_showInputCompleteButton) ...[
                const SizedBox(width: _kSectionSpacing),
                _buildInputCompleteButton(),
              ] else if (_previewUrl != null) ...[
                const SizedBox(width: _kSectionSpacing),
                _buildClearButton(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputCompleteButton() {
    return GestureDetector(
      onTap: _isLoadingPreview ? null : _onInputComplete,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.neutral50),
          borderRadius: BorderRadius.circular(99),
        ),
        child: _isLoadingPreview
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                '입력 완료',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blue500,
                  letterSpacing: -0.025 * 16,
                  height: 1.5,
                ),
              ),
      ),
    );
  }

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: _onClearAll,
      behavior: HitTestBehavior.opaque,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: Icon(Icons.close, size: 20, color: AppColors.gray600),
      ),
    );
  }

  /// 링크 제목 섹션 (미리보기 로드 후 표시, 입력 텍스트 세로 중앙 정렬)
  Widget _buildLinkTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '링크제목',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
            letterSpacing: -0.025 * 18,
            height: 1.25,
          ),
        ),
        const SizedBox(height: _kSectionSpacing),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _linkTitleController,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 16,
              height: 1.375,
            ),
            decoration: const InputDecoration(
              hintText: '제목',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 11),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  /// 링크 설명 섹션 (미리보기 로드 후 표시, 상하 11px 패딩·내용에 따라 높이 확장)
  Widget _buildLinkDescSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '링크설명',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
            letterSpacing: -0.025 * 18,
            height: 1.25,
          ),
        ),
        const SizedBox(height: _kSectionSpacing),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: TextField(
            controller: _linkDescController,
            maxLines: null,
            minLines: 1,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 16,
              height: 1.375,
            ),
            decoration: const InputDecoration(
              hintText: '설명',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              alignLabelWithHint: true,
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
              const SizedBox(width: _kSectionSpacing),
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

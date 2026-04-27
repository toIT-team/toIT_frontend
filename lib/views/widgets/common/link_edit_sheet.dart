import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/system_safe_area.dart';
import '../../../models/dto/page_items_response_dto.dart';
import '../../../repositories/home_repository.dart';

/// 링크 제목·설명 수정 바텀시트 (Figma: 미트볼메뉴-제목수정)
/// [link] 수정 대상 링크, [foldersId] 보관함 ID
/// 저장 성공 시 true로 시트가 닫힘. 호출부에서 await 후 목록 갱신 시 사용.
Future<bool?> showLinkEditSheet(
  BuildContext context, {
  required LinkDto link,
  required int foldersId,
  required WidgetRef ref,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: _LinkEditSheet(link: link, foldersId: foldersId, ref: ref),
    ),
  );
}

class _LinkEditSheet extends ConsumerStatefulWidget {
  final LinkDto link;
  final int foldersId;
  final WidgetRef ref;

  const _LinkEditSheet({
    required this.link,
    required this.foldersId,
    required this.ref,
  });

  @override
  ConsumerState<_LinkEditSheet> createState() => _LinkEditSheetState();
}

class _LinkEditSheetState extends ConsumerState<_LinkEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  bool _isSaving = false;

  static const double _kSpacing = 10;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.link.linksName);
    _descController = TextEditingController(text: widget.link.textContent);
    _titleController.addListener(_onFieldChanged);
    _descController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _descController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// 초기값 대비 변경이 있을 때만 저장 가능
  bool get _hasChanges {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    return title != widget.link.linksName || desc != widget.link.textContent;
  }

  /// 제목이 비어있지 않고, 변경이 있으며, 저장 중이 아닐 때만 저장 가능
  bool get _canSave =>
      _titleController.text.trim().isNotEmpty && _hasChanges && !_isSaving;

  Future<void> _onSave() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.updateLink(
        foldersId: widget.foldersId,
        linksId: widget.link.linksId,
        linksName: title,
        textContent: desc,
      );
      if (!mounted) return;
      ref.invalidate(pageItemsProvider(widget.foldersId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('수정되었습니다.')));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('수정에 실패했습니다. 다시 시도해 주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.neutral50, width: 1),
          left: BorderSide(color: AppColors.neutral50, width: 1),
          right: BorderSide(color: AppColors.neutral50, width: 1),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SystemSafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '정보 수정',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                      letterSpacing: -0.025 * 22,
                      height: 1.5,
                    ),
                  ),
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
                              color: _canSave
                                  ? AppColors.blue500
                                  : AppColors.gray400,
                              letterSpacing: -0.025 * 16,
                              height: 1.4,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: _kSpacing),
              _buildTitleField(),
              const SizedBox(height: _kSpacing),
              _buildDescField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '링크 제목',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
            letterSpacing: -0.025 * 18,
            height: 1.25,
          ),
        ),
        const SizedBox(height: _kSpacing),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: TextField(
            controller: _titleController,
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
              hintText: '제목을 입력하세요',
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

  Widget _buildDescField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '링크 설명',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
            letterSpacing: -0.025 * 18,
            height: 1.25,
          ),
        ),
        const SizedBox(height: _kSpacing),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: TextField(
            controller: _descController,
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
              hintText: '설명을 입력하세요',
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
}

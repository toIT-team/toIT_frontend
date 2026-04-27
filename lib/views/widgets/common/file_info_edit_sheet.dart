import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/system_safe_area.dart';

class AttachmentEditSheetResult {
  const AttachmentEditSheetResult({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

Future<AttachmentEditSheetResult?> showAttachmentInfoEditSheet(
  BuildContext context, {
  required String sheetTitle,
  required String titleLabel,
  required String descriptionLabel,
  required String initialTitle,
  required String initialDescription,
  bool showTitleField = true,
}) {
  return showModalBottomSheet<AttachmentEditSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: _AttachmentInfoEditSheet(
        sheetTitle: sheetTitle,
        titleLabel: titleLabel,
        descriptionLabel: descriptionLabel,
        initialTitle: initialTitle,
        initialDescription: initialDescription,
        showTitleField: showTitleField,
      ),
    ),
  );
}

class _AttachmentInfoEditSheet extends StatefulWidget {
  const _AttachmentInfoEditSheet({
    required this.sheetTitle,
    required this.titleLabel,
    required this.descriptionLabel,
    required this.initialTitle,
    required this.initialDescription,
    required this.showTitleField,
  });

  final String sheetTitle;
  final String titleLabel;
  final String descriptionLabel;
  final String initialTitle;
  final String initialDescription;
  final bool showTitleField;

  @override
  State<_AttachmentInfoEditSheet> createState() =>
      _AttachmentInfoEditSheetState();
}

class _AttachmentInfoEditSheetState extends State<_AttachmentInfoEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  static const double sectionGap = 10;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _descriptionController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get hasChanges {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (widget.showTitleField) {
      return title != widget.initialTitle ||
          description != widget.initialDescription;
    }
    return description != widget.initialDescription;
  }

  bool get canSave {
    if (!hasChanges) return false;
    if (!widget.showTitleField) return true;
    return _titleController.text.trim().isNotEmpty;
  }

  void _submit() {
    if (!canSave) return;
    Navigator.of(context).pop(
      AttachmentEditSheetResult(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
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
                children: [
                  Text(
                    widget.sheetTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                      letterSpacing: -0.025 * 22,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: canSave ? _submit : null,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: canSave ? AppColors.blue500 : AppColors.gray400,
                        letterSpacing: -0.025 * 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.showTitleField) ...[
                const SizedBox(height: sectionGap),
                Text(
                  widget.titleLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                    letterSpacing: -0.025 * 18,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: sectionGap),
                Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 11,
                  ),
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
              const SizedBox(height: sectionGap),
              Text(
                widget.descriptionLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                  letterSpacing: -0.025 * 18,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: sectionGap),
              Container(
                constraints: const BoxConstraints(minHeight: 44),
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                child: TextField(
                  controller: _descriptionController,
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
          ),
        ),
      ),
    );
  }
}

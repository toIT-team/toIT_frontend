import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/dto/page_items_response_dto.dart';
import '../widgets/common/note_kebab_sheet.dart';
import '../widgets/home/folder_delete_dialog.dart';

/// 노트 상세 화면 (Figma: 노트 상세 B-개발완)
/// 상단: 뒤로가기, 제목(내용 일부), 케밥 / 본문: 전체 내용 / 하단: 글자수, 날짜
class NoteDetailScreen extends ConsumerStatefulWidget {
  final TextDto note;
  final int foldersId;

  const NoteDetailScreen({
    super.key,
    required this.note,
    required this.foldersId,
  });

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  late TextDto _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  String _formatDate(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';
    final date = DateTime.tryParse(createdAt);
    if (date == null) return createdAt;
    return '${date.year}.${date.month}.${date.day}';
  }

  void _openKebab() {
    showNoteKebabSheet(
      context,
      note: _note,
      onAction: (action) {
        switch (action) {
          case NoteKebabAction.moveFolder:
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('보관함 이동 (준비 중)')),
              );
            }
            break;
          case NoteKebabAction.delete:
            if (mounted) _confirmAndDelete();
            break;
        }
      },
    );
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDeleteDialog(
      context,
      message: '정말 삭제하시겠습니까?',
    );
    if (confirmed != true || !mounted) return;
    // TODO: DELETE /texts API 연동 후 호출 후 pop
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 (준비 중)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _note.textContent;
    final title = content.length > 30
        ? '${content.substring(0, 30)}...'
        : content.isEmpty
            ? '노트'
            : content;
    final dateText = _formatDate(_note.createdAt);
    final charCount = content.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.gray900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
            letterSpacing: -0.025 * 22,
            height: 1.25,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.gray900),
            onPressed: _openKebab,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Text(
                content.isEmpty
                    ? '링크에 대한 정보를 간단하게 메모해보세요.'
                    : content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray900,
                  letterSpacing: -0.025 * 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$charCount/1000',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 14,
                    height: 1.25,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/dto/page_items_response_dto.dart';

/// 링크 케밥(미트볼) 메뉴 선택 액션
enum LinkKebabAction { editTitle, moveFolder, share, delete }

/// 링크 항목 케밥 메뉴 바텀시트 (Figma: 링크 미트볼메뉴)
///
/// 제목 수정 / 보관함 이동 / 공유 / 삭제 4가지 옵션.
/// [onAction]으로 선택된 액션 전달 후 시트가 닫힘.
void showLinkKebabSheet(
  BuildContext context, {
  required LinkDto link,
  required ValueChanged<LinkKebabAction> onAction,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _LinkKebabSheet(
      link: link,
      onAction: (action) {
        Navigator.of(sheetContext).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) => onAction(action));
      },
    ),
  );
}

class _LinkKebabSheet extends StatelessWidget {
  final LinkDto link;
  final ValueChanged<LinkKebabAction> onAction;

  const _LinkKebabSheet({required this.link, required this.onAction});

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
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSheet,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _buildHandle(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _KebabRow(
                      icon: Icons.drive_file_rename_outline,
                      label: '제목 수정',
                      iconColor: AppColors.gray600,
                      textColor: AppColors.gray900,
                      onTap: () => onAction(LinkKebabAction.editTitle),
                    ),
                    _KebabRow(
                      icon: Icons.drive_file_move_outline,
                      label: '보관함 이동',
                      iconColor: AppColors.gray600,
                      textColor: AppColors.gray900,
                      onTap: () => onAction(LinkKebabAction.moveFolder),
                    ),
                    _KebabRow(
                      icon: Icons.share_outlined,
                      label: '공유',
                      iconColor: AppColors.gray600,
                      textColor: AppColors.gray900,
                      onTap: () => onAction(LinkKebabAction.share),
                    ),
                    _KebabRow(
                      icon: Icons.delete_outline,
                      label: '삭제',
                      iconColor: AppColors.red500,
                      textColor: AppColors.red500,
                      onTap: () => onAction(LinkKebabAction.delete),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 42,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _KebabRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _KebabRow({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  letterSpacing: -0.025 * 18,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

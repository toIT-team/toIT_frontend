import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 보관함 옵션 바텀시트 반환값
enum FolderOption { viewMemo, edit, delete }

/// 보관함 케밥 메뉴 바텀시트 표시
Future<FolderOption?> showFolderOptionsBottomSheet(BuildContext context) {
  return showModalBottomSheet<FolderOption>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.gray900.withOpacity(0.2),
    builder: (context) => const _FolderOptionsSheet(),
  );
}

class _FolderOptionsSheet extends StatelessWidget {
  const _FolderOptionsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.neutral50)),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayScrim,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _buildDragHandle(),
          _OptionItem(
            icon: Icons.description_outlined,
            label: '보관함 메모 보기',
            iconColor: AppColors.gray600,
            textColor: AppColors.gray900,
            onTap: () => Navigator.pop(context, FolderOption.viewMemo),
          ),
          _OptionItem(
            icon: Icons.edit_outlined,
            label: '보관함 수정',
            iconColor: AppColors.gray600,
            textColor: AppColors.gray900,
            onTap: () => Navigator.pop(context, FolderOption.edit),
          ),
          _OptionItem(
            icon: Icons.delete_outline,
            label: '삭제',
            iconColor: AppColors.red500,
            textColor: AppColors.red500,
            onTap: () => Navigator.pop(context, FolderOption.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 42,
        height: 3,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
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
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

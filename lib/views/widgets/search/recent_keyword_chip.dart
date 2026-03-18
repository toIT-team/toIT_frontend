import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// 최근 검색어 둥근 칩
///
/// 검색어 텍스트 + 삭제(×) 아이콘
class RecentKeywordChip extends StatelessWidget {
  const RecentKeywordChip({
    super.key,
    required this.label,
    this.onTap,
    this.onRemove,
  });

  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.borderLight, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 14,
              height: 1.4,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.gray900,
            ),
          ),
        ],
        ),
      ),
    );
  }
}

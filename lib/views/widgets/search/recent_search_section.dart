import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import 'recent_keyword_chip.dart';

/// 최근 검색 섹션
///
/// - 헤더: "최근 검색" + "전체 삭제"
class RecentSearchSection extends StatelessWidget {
  const RecentSearchSection({
    super.key,
    required this.items,
    this.onItemTap,
    this.onDeleteAll,
    this.onRemoveItem,
  });

  final List<String> items;
  final ValueChanged<String>? onItemTap;
  final VoidCallback? onDeleteAll;
  final ValueChanged<String>? onRemoveItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildHeader(),
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildChipList(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '최근 검색',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
            letterSpacing: -0.025 * 18,
            height: 1.25,
          ),
        ),
        GestureDetector(
          onTap: items.isNotEmpty ? onDeleteAll : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              '전체 삭제',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: items.isNotEmpty ? AppColors.gray600 : AppColors.gray400,
                letterSpacing: -0.025 * 14,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipList() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items
          .map(
            (term) => RecentKeywordChip(
              label: term,
              onTap: () => onItemTap?.call(term),
              onRemove: () => onRemoveItem?.call(term),
            ),
          )
          .toList(),
    );
  }
}

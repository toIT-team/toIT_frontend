import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../models/search/search_result_item.dart';
import 'search_result_tile.dart';

/// 검색 결과 섹션
///
/// "결과" 헤더 + 검색 결과 타일 목록
class SearchResultSection extends StatelessWidget {
  const SearchResultSection({
    super.key,
    required this.items,
    this.onItemTap,
  });

  final List<SearchResultItem> items;
  final ValueChanged<SearchResultItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '결과',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 16,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.expand(
          (item) => [
            SearchResultTile(
              item: item,
              onTap: () => onItemTap?.call(item),
            ),
            if (item != items.last)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.neutral50,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

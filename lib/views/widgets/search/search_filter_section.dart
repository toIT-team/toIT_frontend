import 'package:flutter/material.dart';

import '../../../controllers/search_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

extension SearchFilterTypeExtension on SearchFilterType {
  String get label {
    switch (this) {
      case SearchFilterType.link:
        return '링크';
      case SearchFilterType.note:
        return '노트';
      case SearchFilterType.file:
        return '파일';
      case SearchFilterType.schedule:
        return '일정';
    }
  }
}

/// 검색바 하단 필터 칩 섹션
///
/// 링크, 노트, 파일, 일정 필터만 포함 (정렬 미포함)
class SearchFilterSection extends StatelessWidget {
  const SearchFilterSection({
    super.key,
    this.selectedFilter,
    this.onFilterChanged,
  });

  final SearchFilterType? selectedFilter;
  final ValueChanged<SearchFilterType>? onFilterChanged;

  static const List<SearchFilterType> _filters = [
    SearchFilterType.link,
    SearchFilterType.note,
    SearchFilterType.file,
    SearchFilterType.schedule,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: _filters
            .map(
              (filter) => Padding(
                padding: EdgeInsets.only(
                  right: filter != SearchFilterType.schedule
                      ? AppSpacing.sm
                      : 0,
                ),
                child: _FilterChip(
                  label: filter.label,
                  isSelected: selectedFilter == filter,
                  onTap: () => onFilterChanged?.call(filter),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.surface : AppColors.gray600,
            letterSpacing: -0.025 * 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

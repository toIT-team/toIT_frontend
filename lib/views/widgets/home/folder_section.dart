import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_assets.dart';
import '../../../models/home/folder_item.dart';
import 'folder_tile.dart';

/// 폴더 목록 영역
class FolderSection extends StatelessWidget {
  final List<FolderItem> folders;
  final List<String> filters;

  const FolderSection({
    super.key,
    required this.folders,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  '폴더',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
              ],
            ),
            const SizedBox(height: 1.25),
            Row(
              children: [
                Text(
                  '${folders.length}개의 폴더',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text(
                      '최신순',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset(AppAssets.downArrowIcon, width: 18, height: 18),
                  ],
                ),
                const SizedBox(width: 12),
                Image.asset(AppAssets.sortingIcon, width: 24, height: 24),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _ChipsRow(filters: filters),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            for (final f in folders)
              FolderTile(
                title: f.title,
                countText: f.countText,
                accentColor: f.accentColor,
              ),
          ],
        ),
      ],
    );
  }
}

class _ChipsRow extends StatelessWidget {
  final List<String> filters;

  const _ChipsRow({required this.filters});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < filters.length; i++) ...[
            _FilterChip(label: filters[i], selected: i == 0),
            if (i != filters.length - 1) const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF2E9EFA);
    final unselectedText = const Color(0xFF80839C);
    final unselectedBorder = unselectedText.withOpacity(0.35);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? selectedColor : unselectedBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? selectedColor : unselectedText,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_assets.dart';
import '../../../models/home/folder_item.dart';
import 'add_folder_bottom_sheet.dart';
import 'folder_tile.dart';

/// 폴더 목록 영역
class FolderSection extends ConsumerWidget {
  final List<FolderItem> folders;
  final List<String> filters;

  const FolderSection({
    super.key,
    required this.folders,
    required this.filters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalFolderCount = ref.watch(
      homeProvider.select((state) => state.folders.length),
    );
    final isFolderLimitReached =
        totalFolderCount >= HomeController.maxFolderCount;

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
                    color: AppColors.gray900,
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
                  '$totalFolderCount개의 보관함',
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
                        color: AppColors.gray900,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset(AppAssets.downArrowIcon, width: 18, height: 18),
                  ],
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    if (isFolderLimitReached) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('보관함은 최대 20개까지 생성할 수 있습니다.'),
                          ),
                        );
                      }
                      return;
                    }

                    final result = await showAddFolderBottomSheet(context);
                    if (result != null) {
                      final success = await ref
                          .read(homeProvider.notifier)
                          .createFolder(
                            name: result['name'] as String,
                            memo: result['memo'] as String,
                            colorIndex: result['colorIndex'] as int,
                            iconIndex: result['iconIndex'] as int,
                          );
                      if (!success && context.mounted) {
                        final errorMessage =
                            ref.read(homeProvider).errorMessage ??
                            '보관함 생성에 실패했습니다.';
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(errorMessage)));
                      }
                    }
                  },
                  child: Image.asset(
                    AppAssets.addFolderIcon,
                    width: 24,
                    height: 24,
                    color: isFolderLimitReached ? AppColors.gray200 : null,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _ChipsRow(filters: filters),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            // Android Small Phone 같은 좁은 폭 환경에서 카드 하단 overflow를 방지하기 위해
            // 셀 높이를 한 단계 더 확보한다.
            final isNarrowWidth = constraints.maxWidth <= 360;
            final childAspectRatio = isNarrowWidth ? 1.35 : 1.45;

            return GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: childAspectRatio,
              children: [
                for (final f in folders)
                  FolderTile(
                    foldersId: f.foldersId,
                    title: f.title,
                    memo: f.memo,
                    countText: f.countText,
                    accentColor: f.accentColor,
                    colorIndex: f.colorIndex,
                    iconIndex: f.iconIndex,
                  ),
              ],
            );
          },
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
    final selectedColor = AppColors.neutral200;
    final unselectedText = AppColors.gray600;
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

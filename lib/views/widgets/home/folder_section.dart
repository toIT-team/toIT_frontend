import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_assets.dart';
import '../../../models/home/folder_item.dart';
import '../../screens/folder_detail_screen.dart';
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
    final homeNotifier = ref.read(homeProvider.notifier);
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
                  '보관함',
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
                _AddFolderButton(
                  isFolderLimitReached: isFolderLimitReached,
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
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _ChipsRow(
          filters: filters,
          onTapFilter: (index) {
            if (index < 0 || index >= filters.length) return;
            ref.read(homeProvider.notifier).selectFilter(index);
            final filterToken = filters[index];
            if (!homeNotifier.isFolderShortcutFilter(filterToken)) return;

            final folderId = homeNotifier.getFolderShortcutId(filterToken);
            if (folderId == null) return;
            final targetFolder = folders.where(
              (folder) => folder.foldersId == folderId,
            );
            if (targetFolder.isEmpty) return;

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FolderDetailScreen(
                  foldersId: targetFolder.first.foldersId,
                  folderName: targetFolder.first.title,
                ),
              ),
            );
          },
          filterLabelBuilder: homeNotifier.getFilterLabel,
        ),
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
  final ValueChanged<int> onTapFilter;
  final String Function(String filterToken) filterLabelBuilder;

  const _ChipsRow({
    required this.filters,
    required this.onTapFilter,
    required this.filterLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < filters.length; i++) ...[
            _FilterChip(
              label: filterLabelBuilder(filters[i]),
              onTap: () => onTapFilter(i),
            ),
            if (i != filters.length - 1) const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool isPressed = false;

  void setPressed(bool nextValue) {
    if (isPressed == nextValue) return;
    setState(() {
      isPressed = nextValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseTextColor = AppColors.gray600;
    final baseBorderColor = baseTextColor.withOpacity(0.35);

    return AnimatedScale(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      scale: isPressed ? 0.95 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: setPressed,
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isPressed
                  ? AppColors.neutral100.withOpacity(0.55)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: baseBorderColor),
            ),
            child: Text(
              widget.label,
              style: const TextStyle(
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddFolderButton extends StatefulWidget {
  const _AddFolderButton({
    required this.isFolderLimitReached,
    required this.onTap,
  });

  final bool isFolderLimitReached;
  final VoidCallback onTap;

  @override
  State<_AddFolderButton> createState() => _AddFolderButtonState();
}

class _AddFolderButtonState extends State<_AddFolderButton> {
  bool isPressed = false;

  void setPressed(bool nextValue) {
    if (isPressed == nextValue) return;
    setState(() {
      isPressed = nextValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      scale: isPressed ? 0.9 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: setPressed,
          borderRadius: BorderRadius.circular(99),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              AppAssets.addFolderIcon,
              width: 24,
              height: 24,
              color: widget.isFolderLimitReached ? AppColors.gray200 : null,
            ),
          ),
        ),
      ),
    );
  }
}

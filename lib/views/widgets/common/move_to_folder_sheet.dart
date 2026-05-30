import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/system_safe_area.dart';
import '../../../models/home/folder_item.dart';
import '../home/folder_tile.dart';
import '../search/search_field_widget.dart';
import 'app_snack_bar.dart';

/// 보관함 이동 바텀시트 표시 (링크/노트/파일/이미지 탭 케밥 메뉴에서 공통 사용)
///
/// [currentFoldersId] 현재 보관함 ID (선택 불가, 50% opacity 표시)
/// [onSelect] 이동할 보관함 선택 시 콜백
Future<void> showMoveToFolderSheet(
  BuildContext context,
  WidgetRef ref, {
  required int currentFoldersId,
  required ValueChanged<FolderItem> onSelect,
}) async {
  final folders = ref.read(homeProvider).folders;
  if (folders.isEmpty) {
    if (context.mounted) {
      showAppSnackBar(context, '보관함이 없습니다. 먼저 보관함을 만들어 주세요.');
    }
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => MoveToFolderSheet(
      folders: folders,
      currentFoldersId: currentFoldersId,
      onSelect: (folder) {
        onSelect(folder);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

/// 보관함 이동 바텀시트 본문 (피그마: 미트볼메뉴-보관함 이동, 메인 폴더 디자인과 동일)
class MoveToFolderSheet extends ConsumerStatefulWidget {
  const MoveToFolderSheet({
    super.key,
    required this.folders,
    required this.currentFoldersId,
    required this.onSelect,
  });

  final List<FolderItem> folders;
  final int currentFoldersId;
  final ValueChanged<FolderItem> onSelect;

  @override
  ConsumerState<MoveToFolderSheet> createState() => _MoveToFolderSheetState();
}

class _MoveToFolderSheetState extends ConsumerState<MoveToFolderSheet> {
  final TextEditingController _searchController = TextEditingController();
  static const List<String> _filterChipLabels = ['전체', '즐겨찾기'];

  /// 0: 전체, 1: 즐겨찾기
  int _filterChipIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FolderItem> get _filteredFolders {
    final query = _searchController.text.trim().toLowerCase();
    var list = query.isEmpty
        ? widget.folders
        : widget.folders
            .where((f) => f.title.toLowerCase().contains(query))
            .toList();
    if (_filterChipIndex == 1) {
      list = list.where((f) => f.isFavorite).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.neutral50),
          left: BorderSide(color: AppColors.neutral50),
          right: BorderSide(color: AppColors.neutral50),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSheet,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.76,
      ),
      child: SystemSafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDragHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: _buildSearchBar(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildCountAndChips(),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: _filteredFolders.isEmpty
                  ? _buildEmptyState()
                  : _buildFolderGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Center(
        child: Container(
          width: 42,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchFieldWidget(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
    );
  }

  /// 피그마: "N개의 보관함" + 칩 row (전체 선택 시 primary, 나머지 D9D9D9/80839C)
  Widget _buildCountAndChips() {
    final count = _filteredFolders.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$count개의 보관함',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
                letterSpacing: -0.025 * 16,
                height: 1.5,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < _filterChipLabels.length; i++) ...[
                _MoveSheetChip(
                  label: _filterChipLabels[i],
                  selected: i == _filterChipIndex,
                  onTap: () {
                    if (_filterChipIndex == i) return;
                    setState(() => _filterChipIndex = i);
                  },
                ),
                if (i != _filterChipLabels.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 40, color: AppColors.gray900),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 18,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '검색어를 확인해주시거나 다시 시도해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
                letterSpacing: -0.025 * 16,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메인 화면과 동일: 2열 그리드 + FolderTile, 현재 보관함 50% opacity
  Widget _buildFolderGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.5,
        children: [
          for (final folder in _filteredFolders) ...[
            Opacity(
              opacity: folder.foldersId == widget.currentFoldersId ? 0.5 : 1,
              child: FolderTile(
                foldersId: folder.foldersId,
                title: folder.title,
                memo: folder.memo,
                countText: folder.countText,
                accentColor: folder.accentColor,
                colorIndex: folder.colorIndex,
                iconIndex: folder.iconIndex,
                onTap: folder.foldersId == widget.currentFoldersId
                    ? () {}
                    : () => widget.onSelect(folder),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 피그마: 전체(선택 시 main border+text), 그 외 border #D9D9D9, color #80839C
class _MoveSheetChip extends StatelessWidget {
  const _MoveSheetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selected ? AppColors.blue500 : AppColors.borderLight,
            ),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.blue500 : AppColors.gray600,
              letterSpacing: -0.025 * 16,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

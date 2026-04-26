import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/system_safe_area.dart';
import '../../../core/utils/search_folder_mapper.dart';
import '../../../models/dto/search_response_dto.dart';
import '../../../models/home/folder_item.dart';
import '../../../services/search_api_client.dart';
import '../home/folder_tile.dart';
import '../search/search_field_widget.dart';

/// 일정 폼에서 보관함을 고를 때 쓰는 검색 바텀시트.
///
/// 검색어가 비어 있으면 홈 보관함 목록을 보여 주고, 입력 시 [SearchApiClient]로
/// `GET /page/search`를 호출해 폴더만 표시한다.
Future<void> showScheduleFolderSearchSheet(
  BuildContext context,
  WidgetRef ref, {
  required ValueChanged<FolderItem> onSelected,
}) async {
  final folders = ref.read(homeProvider).folders;
  if (folders.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('보관함이 없습니다. 먼저 보관함을 만들어 주세요.'),
        ),
      );
    }
    return;
  }

  // 타이틀 등 상위 폼 포커스가 남으면 시트 위에 키보드가 겹친다.
  FocusManager.instance.primaryFocus?.unfocus();

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => ScheduleFolderSearchSheet(
      onSelect: (folder) {
        onSelected(folder);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

/// 일정용 보관함 검색 시트 본문
class ScheduleFolderSearchSheet extends ConsumerStatefulWidget {
  const ScheduleFolderSearchSheet({
    super.key,
    required this.onSelect,
  });

  final ValueChanged<FolderItem> onSelect;

  @override
  ConsumerState<ScheduleFolderSearchSheet> createState() =>
      _ScheduleFolderSearchSheetState();
}

class _ScheduleFolderSearchSheetState
    extends ConsumerState<ScheduleFolderSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  static const List<String> _filterChipLabels = ['전체', '즐겨찾기'];

  /// 0: 전체, 1: 즐겨찾기
  int _filterChipIndex = 0;

  bool _isSearching = false;
  List<FolderItem> _searchFolders = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String _) {
    _debounce?.cancel();
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchFolders = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(q);
    });
  }

  Future<void> _runSearch(String query) async {
    final api = ref.read(searchApiClientProvider);
    final homeFolders = ref.read(homeProvider).folders;
    try {
      final dto = await api.search(keyword: query);
      if (!mounted) return;
      if (_searchController.text.trim() != query) return;

      final mapped = _mapFolders(dto.folders, homeFolders);
      setState(() {
        _isSearching = false;
        _searchFolders = mapped;
      });
    } catch (_) {
      if (!mounted) return;
      if (_searchController.text.trim() != query) return;
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색 중 오류가 발생했습니다.')),
      );
    }
  }

  List<FolderItem> _mapFolders(
    List<SearchFolderItemDto> dtos,
    List<FolderItem> homeFolders,
  ) {
    final out = <FolderItem>[];
    for (var i = 0; i < dtos.length; i++) {
      out.add(folderItemFromSearchFolderDto(dtos[i], homeFolders));
    }
    return out;
  }

  List<FolderItem> get _displayFolders {
    final q = _searchController.text.trim();
    final List<FolderItem> base = q.isEmpty
        ? ref.watch(homeProvider).folders
        : _searchFolders;
    if (_filterChipIndex == 1) {
      return base.where((f) => f.isFavorite).toList();
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchController.text.trim();
    final showLoading = q.isNotEmpty && _isSearching;
    final folders = _displayFolders;
    final count = folders.length;
    final screenH = MediaQuery.sizeOf(context).height;

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
        maxHeight: screenH * 0.9,
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
              child: SearchFieldWidget(
                controller: _searchController,
                onChanged: _onQueryChanged,
                // 시트 오픈 직후 자동 포커스면 키보드+시트가 함께 올라간다.
                autofocus: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildCountAndChips(count),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: showLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (q.isNotEmpty && folders.isEmpty)
                      ? _buildEmptyState()
                      : _buildFolderGrid(folders),
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

  Widget _buildCountAndChips(int count) {
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
                _ScheduleFolderChip(
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

  Widget _buildFolderGrid(List<FolderItem> folderList) {
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
          for (final folder in folderList)
            FolderTile(
              foldersId: folder.foldersId,
              title: folder.title,
              memo: folder.memo,
              countText: folder.countText,
              accentColor: folder.accentColor,
              colorIndex: folder.colorIndex,
              onTap: () => widget.onSelect(folder),
            ),
        ],
      ),
    );
  }
}

class _ScheduleFolderChip extends StatelessWidget {
  const _ScheduleFolderChip({
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

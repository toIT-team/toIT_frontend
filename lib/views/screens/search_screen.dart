import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/folder_tab_index.dart';
import '../../controllers/search_controller.dart';
import '../../models/dto/page_items_response_dto.dart';
import '../../models/search/search_result_item.dart';
import 'event_detail_screen.dart';
import 'folder_detail_screen.dart';
import 'note_detail_screen.dart';
import '../widgets/search/recent_search_section.dart';
import '../widgets/search/search_bar_widget.dart';
import '../widgets/search/search_filter_section.dart';
import '../widgets/search/search_result_section.dart';

/// 검색 화면
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(searchProvider.notifier).onQueryChanged(value);
  }

  void _onRecentKeywordTap(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: term.length),
    );
    ref.read(searchProvider.notifier).onQueryChanged(term);
  }

  void _onSearchResultTap(SearchResultItem item) {
    switch (item.type) {
      case SearchResultType.folder:
        if (item.foldersId == null || item.foldersId! <= 0) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FolderDetailScreen(
              foldersId: item.foldersId!,
              folderName: item.title,
              initialTab: FolderTab.links,
            ),
          ),
        );
      case SearchResultType.schedule:
        if (item.schedulesId == null || item.schedulesId! <= 0) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => EventDetailScreen(
              schedulesId: item.schedulesId!,
            ),
          ),
        );
      case SearchResultType.link:
        if (item.foldersId == null || item.foldersId! <= 0) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FolderDetailScreen(
              foldersId: item.foldersId!,
              folderName: item.foldersName?.isNotEmpty == true
                  ? item.foldersName!
                  : '보관함',
              initialTab: FolderTab.links,
            ),
          ),
        );
      case SearchResultType.note:
        if (item.foldersId == null ||
            item.foldersId! <= 0 ||
            item.textsId == null ||
            item.textsId! <= 0) {
          return;
        }
        final note = TextDto(
          textsId: item.textsId!,
          textContent: item.textContent ?? '',
          createdAt: item.createdAt,
        );
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NoteDetailScreen(
              note: note,
              foldersId: item.foldersId!,
            ),
          ),
        );
      case SearchResultType.file:
        if (item.foldersId == null || item.foldersId! <= 0) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FolderDetailScreen(
              foldersId: item.foldersId!,
              folderName: item.foldersName?.isNotEmpty == true
                  ? item.foldersName!
                  : '보관함',
              initialTab: FolderTab.files,
            ),
          ),
        );
      case SearchResultType.image:
        if (item.foldersId == null || item.foldersId! <= 0) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FolderDetailScreen(
              foldersId: item.foldersId!,
              folderName: item.foldersName?.isNotEmpty == true
                  ? item.foldersName!
                  : '보관함',
              initialTab: FolderTab.images,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchBarWidget(
            controller: _searchController,
            onChanged: _onQueryChanged,
          ),
          SearchFilterSection(
            selectedFilter: searchState.selectedFilter,
            onFilterChanged: (f) =>
                ref.read(searchProvider.notifier).setFilter(f),
          ),
          Expanded(
            child: _buildBody(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    final query = state.query.trim();

    if (query.isEmpty) {
      return SingleChildScrollView(
        child: RecentSearchSection(
          items: state.recentKeywords,
          onItemTap: _onRecentKeywordTap,
          onDeleteAll: () =>
              ref.read(searchProvider.notifier).clearRecentKeywords(),
          onRemoveItem: (term) =>
              ref.read(searchProvider.notifier).removeRecentKeyword(term),
        ),
      );
    }

    switch (state.status) {
      case SearchStatus.initial:
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.errorMessage ?? '오류가 발생했습니다.',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        );
      case SearchStatus.loaded:
        return SingleChildScrollView(
          child: SearchResultSection(
            items: state.items,
            onItemTap: _onSearchResultTap,
          ),
        );
    }
  }
}

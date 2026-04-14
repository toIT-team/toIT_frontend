import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/utils/search_utils.dart';
import '../models/dto/search_response_dto.dart';
import '../models/search/search_result_item.dart';
import '../services/search_api_client.dart'
    show SearchApiClient, searchApiClientProvider;

part 'search_controller.freezed.dart';

/// 검색 결과 필터 타입
enum SearchFilterType {
  link,
  note,
  file,
  schedule,
}

/// 검색 상태
enum SearchStatus { initial, loading, loaded, error }

/// LRU + TTL 캐시 설정
const int _cacheMaxSize = 12;
const Duration _cacheTtl = Duration(minutes: 2);

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    @Default(SearchStatus.initial) SearchStatus status,
    @Default([]) List<SearchResultItem> items,
    SearchFilterType? selectedFilter,
    @Default([]) List<String> recentKeywords,
    String? errorMessage,
  }) = _SearchState;
}

/// LRU + TTL 검색 결과 캐시
class _SearchResultCache {
  _SearchResultCache();

  final Map<String, _CacheEntry> _cache = {};
  final List<String> _keyOrder = [];

  List<SearchResultItem>? get(String keyword) {
    final key = _normalizeKey(keyword);
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > _cacheTtl) {
      _remove(key);
      return null;
    }
    _touch(key);
    return entry.items;
  }

  void put(String keyword, List<SearchResultItem> items) {
    final key = _normalizeKey(keyword);
    if (key.isEmpty) return;

    if (_cache.containsKey(key)) {
      _touch(key);
    } else {
      while (_cache.length >= _cacheMaxSize && _keyOrder.isNotEmpty) {
        _remove(_keyOrder.first);
      }
      _keyOrder.add(key);
    }
    _cache[key] = _CacheEntry(items: items, timestamp: DateTime.now());
  }

  void _touch(String key) {
    _keyOrder.remove(key);
    _keyOrder.add(key);
  }

  void _remove(String key) {
    _cache.remove(key);
    _keyOrder.remove(key);
  }

  String _normalizeKey(String keyword) =>
      keyword.trim().toLowerCase();
}

class _CacheEntry {
  _CacheEntry({required this.items, required this.timestamp});

  final List<SearchResultItem> items;
  final DateTime timestamp;
}

/// SearchResponseDto → SearchResultItem 변환
List<SearchResultItem> _toSearchResultItems(SearchResponseDto dto) {
  final items = <SearchResultItem>[];
  final folderNames = {
    for (final f in dto.folders) f.foldersId: f.name,
  };

  for (final f in dto.folders) {
    items.add(SearchResultItem(
      id: 'folder_${f.foldersId}',
      type: SearchResultType.folder,
      title: f.name,
      subtitle: '보관함',
      foldersId: f.foldersId,
      foldersName: f.name,
    ));
  }

  for (final s in dto.schedules) {
    items.add(SearchResultItem(
      id: 'schedule_${s.schedulesId}',
      type: SearchResultType.schedule,
      title: s.title,
      subtitle: '일정 | ${SearchUtils.formatDateSubtitle(s.startDate)}',
      foldersId: s.foldersId,
      foldersName: s.foldersTitle,
      schedulesId: s.schedulesId,
    ));
  }

  for (final l in dto.links) {
    final title = l.linksName.isNotEmpty ? l.linksName : l.linksUrl;
    items.add(SearchResultItem(
      id: 'link_${l.linksId}',
      type: SearchResultType.link,
      title: title,
      subtitle: '링크 | ${SearchUtils.formatDateFromIso(l.createdAt)}',
      foldersId: l.foldersId,
      foldersName: folderNames[l.foldersId],
    ));
  }

  for (final t in dto.texts) {
    final title = t.textContent.length > 20
        ? '${t.textContent.substring(0, 20)}...'
        : (t.textContent.isEmpty ? '노트' : t.textContent);
    items.add(SearchResultItem(
      id: 'text_${t.textsId}',
      type: SearchResultType.note,
      title: title,
      subtitle: '노트 | ${SearchUtils.formatDateFromIso(t.createdAt)}',
      foldersId: t.foldersId,
      foldersName: folderNames[t.foldersId],
      textsId: t.textsId,
      textContent: t.textContent,
      createdAt: t.createdAt,
    ));
  }

  for (final f in dto.files) {
    items.add(SearchResultItem(
      id: 'file_${f.attachmentsId}',
      type: SearchResultType.file,
      title: f.fileName,
      subtitle: '파일 | ${SearchUtils.formatDateFromIso(f.createdAt)}',
      foldersId: f.foldersId,
      foldersName: folderNames[f.foldersId],
    ));
  }

  return items;
}

/// 필터 적용
List<SearchResultItem> _applyFilter(
  List<SearchResultItem> items,
  SearchFilterType? filter,
) {
  if (filter == null) return items;
  switch (filter) {
    case SearchFilterType.link:
      return items.where((i) => i.isLink).toList();
    case SearchFilterType.note:
      return items.where((i) => i.isNote).toList();
    case SearchFilterType.file:
      return items.where((i) => i.isFile).toList();
    case SearchFilterType.schedule:
      return items.where((i) => i.isSchedule).toList();
  }
}

/// 검색 컨트롤러
class SearchController extends Notifier<SearchState> {
  late final SearchApiClient _apiClient;
  final _SearchResultCache _cache = _SearchResultCache();
  Timer? _debounceTimer;

  @override
  SearchState build() {
    _apiClient = ref.watch(searchApiClientProvider);
    return const SearchState();
  }

  /// 검색어 변경 (debounce 300ms)
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    state = state.copyWith(query: query);

    if (query.trim().isEmpty) {
      state = state.copyWith(
        status: SearchStatus.initial,
        items: [],
        errorMessage: null,
      );
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    final cached = _cache.get(query);
    if (cached != null) {
      state = state.copyWith(
        status: SearchStatus.loaded,
        items: _applyFilter(cached, state.selectedFilter),
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(
      status: SearchStatus.loading,
      errorMessage: null,
    );

    try {
      final dto = await _apiClient.search(
        keyword: query,
      );
      final items = _toSearchResultItems(dto);
      _cache.put(query, items);

      if (state.query.trim() != query) return;

      addRecentKeyword(query);
      state = state.copyWith(
        status: SearchStatus.loaded,
        items: _applyFilter(items, state.selectedFilter),
        errorMessage: null,
      );
    } catch (e) {
      if (state.query.trim() != query) return;
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: '검색 중 오류가 발생했습니다.',
      );
    }
  }

  /// 필터 변경
  void setFilter(SearchFilterType? filter) {
    state = state.copyWith(selectedFilter: filter);
    if (state.query.trim().isEmpty) return;

    final cached = _cache.get(state.query);
    if (cached != null) {
      state = state.copyWith(
        items: _applyFilter(cached, filter),
      );
    }
  }

  /// 최근 검색어 추가
  void addRecentKeyword(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    var list = List<String>.from(state.recentKeywords);
    list.remove(trimmed);
    list.insert(0, trimmed);
    if (list.length > 10) list = list.sublist(0, 10);
    state = state.copyWith(recentKeywords: list);
  }

  /// 최근 검색어 전체 삭제
  void clearRecentKeywords() {
    state = state.copyWith(recentKeywords: []);
  }

  /// 최근 검색어 개별 삭제
  void removeRecentKeyword(String keyword) {
    final list = state.recentKeywords.where((k) => k != keyword).toList();
    state = state.copyWith(recentKeywords: list);
  }
}

final searchProvider =
    NotifierProvider<SearchController, SearchState>(
  SearchController.new,
);

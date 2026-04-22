import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:poj_todo/controllers/search_controller.dart';
import 'package:poj_todo/models/dto/search_response_dto.dart';
import 'package:poj_todo/models/search/search_result_item.dart';
import 'package:poj_todo/services/search_api_client.dart';

class _StubSearchApi extends SearchApiClient {
  _StubSearchApi() : super(dio: Dio());

  @override
  Future<SearchResponseDto> search({required String keyword}) async {
    return const SearchResponseDto(
      folders: [
        SearchFolderItemDto(foldersId: 1, name: '보관함 A'),
      ],
      schedules: [
        SearchScheduleItemDto(
          schedulesId: 10,
          title: '일정 1',
          foldersId: 0,
          foldersTitle: '',
        ),
      ],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    '동일 필터 재선택 시 해제되고, 보관함 필터는 폴더 결과만 남긴다',
    () async {
      final container = ProviderContainer(
        overrides: [
          searchApiClientProvider.overrideWithValue(_StubSearchApi()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('키워드');
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final loaded = container.read(searchProvider);
      expect(loaded.status, SearchStatus.loaded);
      expect(loaded.items.length, greaterThanOrEqualTo(2));

      notifier.setFilter(SearchFilterType.schedule);
      expect(
        container.read(searchProvider).selectedFilter,
        SearchFilterType.schedule,
      );

      notifier.setFilter(SearchFilterType.schedule);
      expect(container.read(searchProvider).selectedFilter, isNull);

      notifier.setFilter(SearchFilterType.archive);
      final archived = container.read(searchProvider).items;
      expect(archived.length, 1);
      expect(archived.single.type, SearchResultType.folder);
    },
  );
}

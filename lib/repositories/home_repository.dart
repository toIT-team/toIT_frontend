import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../datasources/remote/home_remote_datasource.dart';
import '../models/dto/home_response_dto.dart';
import '../models/dto/page_items_response_dto.dart';

/// 홈 화면 리포지토리
/// - Remote/Local DataSource 선택
/// - DTO → Domain 변환 수행
class HomeRepository {
  final HomeRemoteDatasource _remoteDatasource;

  const HomeRepository(this._remoteDatasource);

  /// 홈 화면 데이터 조회
  /// [todayDate] 오늘 날짜 (yyyy-MM-dd)
  Future<HomeResponseDto> fetchHomeData({required String todayDate}) async {
    // TODO: 로그인 구현 후 실제 userId 사용
    final response = await _remoteDatasource.fetchHomeData(
      usersId: ApiConstants.defaultUsersId,
      todayDate: todayDate,
    );

    return response;
  }

  /// 보관함(폴더) 삭제
  Future<void> deleteFolder({required int foldersId}) async {
    await _remoteDatasource.deleteFolder(
      usersId: ApiConstants.defaultUsersId,
      foldersId: foldersId,
    );
  }

  /// 보관함(폴더) 수정
  Future<void> updateFolder({
    required int foldersId,
    required String name,
    required String memo,
    required String color,
  }) async {
    await _remoteDatasource.updateFolder(
      usersId: ApiConstants.defaultUsersId,
      foldersId: foldersId,
      name: name,
      memo: memo,
      color: color,
    );
  }

  /// 보관함 내부 항목 조회 (GET /page/items)
  Future<PageItemsResponseDto> getPageItems({required int foldersId}) async {
    return _remoteDatasource.fetchPageItems(
      usersId: ApiConstants.defaultUsersId,
      foldersId: foldersId,
    );
  }

  /// 보관함(폴더) 생성
  Future<FolderDto> createFolder({
    required String name,
    required String memo,
    required String color,
  }) async {
    return _remoteDatasource.createFolder(
      usersId: ApiConstants.defaultUsersId,
      name: name,
      memo: memo,
      color: color,
    );
  }
}

/// HomeRemoteDatasource Provider
final homeRemoteDatasourceProvider = Provider<HomeRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRemoteDatasource(apiClient);
});

/// HomeRepository Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDatasource = ref.watch(homeRemoteDatasourceProvider);
  return HomeRepository(remoteDatasource);
});

/// 보관함 상세 항목 (GET /page/items) - foldersId별 캐시
final pageItemsProvider = FutureProvider.family<PageItemsResponseDto, int>((
  ref,
  foldersId,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getPageItems(foldersId: foldersId);
});

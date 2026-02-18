import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../datasources/remote/home_remote_datasource.dart';
import '../models/dto/home_response_dto.dart';

/// 홈 화면 리포지토리
/// - Remote/Local DataSource 선택
/// - DTO → Domain 변환 수행
class HomeRepository {
  final HomeRemoteDatasource _remoteDatasource;

  const HomeRepository(this._remoteDatasource);

  /// 홈 화면 데이터 조회
  /// [todayDate] 오늘 날짜 (yyyy-MM-dd)
  Future<HomeResponseDto> fetchHomeData({
    required String todayDate,
  }) async {
    // TODO: 로그인 구현 후 실제 userId 사용
    final response = await _remoteDatasource.fetchHomeData(
      usersId: ApiConstants.defaultUsersId,
      todayDate: todayDate,
    );

    return response;
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

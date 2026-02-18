import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/dto/home_response_dto.dart';

/// 홈 화면 원격 데이터 소스 (API 통신)
class HomeRemoteDatasource {
  final ApiClient _apiClient;

  const HomeRemoteDatasource(this._apiClient);

  /// 홈 화면 데이터 조회
  /// [usersId] 사용자 ID
  /// [todayDate] 오늘 날짜 (yyyy-MM-dd)
  Future<HomeResponseDto> fetchHomeData({
    required int usersId,
    required String todayDate,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.homePageEndpoint,
      queryParameters: {'usersId': usersId, 'todayDate': todayDate},
    );

    return HomeResponseDto.fromJson(response.data as Map<String, dynamic>);
  }
}

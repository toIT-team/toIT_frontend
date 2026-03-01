import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/dto/home_response_dto.dart';
import '../../models/dto/page_items_response_dto.dart';

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

  /// 보관함(폴더) 생성
  Future<FolderDto> createFolder({
    required int usersId,
    required String name,
    required String memo,
    required String color,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.foldersEndpoint,
      data: {'usersId': usersId, 'name': name, 'memo': memo, 'color': color},
    );

    return FolderDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// 보관함(폴더) 삭제 (Soft Delete)
  Future<void> deleteFolder({
    required int usersId,
    required int foldersId,
  }) async {
    await _apiClient.delete(
      ApiConstants.foldersEndpoint,
      data: {'usersId': usersId, 'foldersId': foldersId},
    );
  }

  /// 자료 링크 추가 (POST /links)
  /// [foldersIdList] 링크를 저장할 보관함 ID 목록 (복수 선택 가능)
  Future<void> createLink({
    required int usersId,
    required List<int> foldersIdList,
    required String linksUrl,
  }) async {
    await _apiClient.post(
      ApiConstants.linksEndpoint,
      data: {
        'usersId': usersId,
        'foldersIdList': foldersIdList,
        'linksUrl': linksUrl,
      },
    );
  }

  /// 자료 텍스트(노트) 추가 (POST /texts)
  /// [foldersIdList] 노트를 저장할 보관함 ID 목록
  Future<void> createText({
    required int usersId,
    required List<int> foldersIdList,
    required String textContent,
  }) async {
    await _apiClient.post(
      ApiConstants.textsEndpoint,
      data: {
        'usersId': usersId,
        'foldersIdList': foldersIdList,
        'textContent': textContent,
      },
    );
  }

  /// 자료 파일 추가 (POST /attachments/files)
  /// Query: usersId, foldersIdList, textContent. Body: multipart/form-data (file 파트)
  Future<void> createFile({
    required int usersId,
    required List<int> foldersIdList,
    required String textContent,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes is Uint8List ? fileBytes : Uint8List.fromList(fileBytes),
        filename: fileName,
      ),
    });
    await _apiClient.post(
      ApiConstants.attachmentsFilesEndpoint,
      queryParameters: {
        'usersId': usersId,
        'foldersIdList': ListParam(foldersIdList, ListFormat.multi),
        'textContent': textContent,
      },
      data: formData,
    );
  }

  /// 보관함 내부 항목 조회 (링크/노트/파일/이미지)
  Future<PageItemsResponseDto> fetchPageItems({
    required int usersId,
    required int foldersId,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.pageItemsEndpoint,
      queryParameters: {'usersId': usersId, 'foldersId': foldersId},
    );

    return PageItemsResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// 보관함(폴더) 수정
  Future<void> updateFolder({
    required int usersId,
    required int foldersId,
    required String name,
    required String memo,
    required String color,
    int iconIdx = 0,
  }) async {
    await _apiClient.patch(
      ApiConstants.foldersEndpoint,
      data: {
        'usersId': usersId,
        'foldersId': foldersId,
        'name': name,
        'memo': memo,
        'color': color,
        'iconIdx': iconIdx,
      },
    );
  }
}

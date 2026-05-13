import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/dto/attachment_confirm_dto.dart';
import '../../models/dto/attachment_presign_dto.dart';
import '../../models/dto/home_response_dto.dart';
import '../../models/dto/link_preview_response_dto.dart';
import '../../models/dto/page_items_response_dto.dart';

/// 홈 화면 원격 데이터 소스 (API 통신)
class HomeRemoteDatasource {
  final ApiClient _apiClient;

  const HomeRemoteDatasource(this._apiClient);

  /// 홈 화면 데이터 조회
  /// [todayDate] 오늘 날짜 (yyyy-MM-dd)
  Future<HomeResponseDto> fetchHomeData({required String todayDate}) async {
    final response = await _apiClient.get(
      ApiConstants.homePageEndpoint,
      queryParameters: {'todayDate': todayDate},
    );

    return HomeResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// 보관함(폴더) 생성
  Future<FolderDto> createFolder({
    required String name,
    required String memo,
    required String color,
    required int iconIdx,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.foldersEndpoint,
      data: {'name': name, 'memo': memo, 'color': color, 'iconIdx': iconIdx},
    );

    return FolderDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// 보관함(폴더) 삭제 (Soft Delete)
  Future<void> deleteFolder({required int foldersId}) async {
    await _apiClient.delete(
      ApiConstants.foldersEndpoint,
      data: {'foldersId': foldersId},
    );
  }

  /// 보관함 즐겨찾기 토글 (PATCH /folders/favorite)
  Future<bool> toggleFolderFavorite({
    required int foldersId,
    required bool isFavorite,
  }) async {
    final response = await _apiClient.patch(
      ApiConstants.foldersFavoriteEndpoint,
      data: {'foldersId': foldersId, 'isFavorite': isFavorite},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['isFavorite'] is bool) {
      return data['isFavorite'] as bool;
    }
    return isFavorite;
  }

  /// 링크 미리보기 추출 (POST /links/preview)
  /// [linksUrl]을 받아 링크 제목, 본문, 썸네일 추출
  Future<LinkPreviewResponseDto> fetchLinkPreview({
    required String linksUrl,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.linksPreviewEndpoint,
      data: {'linksUrl': linksUrl},
    );
    return LinkPreviewResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// 자료 링크 추가 (POST /links)
  /// [foldersIdList] 링크를 저장할 보관함 ID 목록 (복수 선택 가능)
  /// [linksName], [textContent], [linksThumbnail] 미리보기에서 추출한 값(선택)
  Future<void> createLink({
    required List<int> foldersIdList,
    required String linksUrl,
    String? linksName,
    String? textContent,
    String? linksThumbnail,
  }) async {
    final data = <String, dynamic>{
      'foldersIdList': foldersIdList,
      'linksUrl': linksUrl,
    };
    if (linksName != null && linksName.isNotEmpty)
      data['linksName'] = linksName;
    if (textContent != null && textContent.isNotEmpty) {
      data['textContent'] = textContent;
    }
    if (linksThumbnail != null && linksThumbnail.isNotEmpty) {
      data['linksThumbnail'] = linksThumbnail;
    }
    await _apiClient.post(ApiConstants.linksEndpoint, data: data);
  }

  /// 자료 링크 삭제 (DELETE /links)
  /// Body: foldersId, linksId
  Future<void> deleteLink({
    required int foldersId,
    required int linksId,
  }) async {
    await _apiClient.delete(
      ApiConstants.linksEndpoint,
      data: {'foldersId': foldersId, 'linksId': linksId},
    );
  }

  /// 자료 링크 수정 (PATCH /links/update) - 제목·설명
  Future<void> updateLink({
    required int foldersId,
    required int linksId,
    required String linksName,
    required String textContent,
  }) async {
    await _apiClient.patch(
      ApiConstants.linksUpdateEndpoint,
      data: {
        'foldersId': foldersId,
        'linksId': linksId,
        'linksName': linksName,
        'textContent': textContent,
      },
    );
  }

  /// 자료 링크 보관함 이동 (PATCH /links) - Body: moveFoldersId
  Future<void> moveLink({
    required int foldersId,
    required int moveFoldersId,
    required int linksId,
  }) async {
    await _apiClient.patch(
      ApiConstants.linksEndpoint,
      data: {
        'foldersId': foldersId,
        'moveFoldersId': moveFoldersId,
        'linksId': linksId,
      },
    );
  }

  /// 자료 텍스트(노트) 추가 (POST /texts)
  /// [foldersIdList] 노트를 저장할 보관함 ID 목록
  Future<void> createText({
    required List<int> foldersIdList,
    required String textContent,
  }) async {
    await _apiClient.post(
      ApiConstants.textsEndpoint,
      data: {'foldersIdList': foldersIdList, 'textContent': textContent},
    );
  }

  /// 자료 텍스트(노트) 수정 (PATCH /texts/update)
  Future<void> updateText({
    required int foldersId,
    required int textsId,
    required String textContent,
  }) async {
    await _apiClient.patch(
      ApiConstants.textsUpdateEndpoint,
      data: {
        'foldersId': foldersId,
        'textsId': textsId,
        'textContent': textContent,
      },
    );
  }

  /// 자료 텍스트(노트) 삭제 (DELETE /texts)
  Future<void> deleteText({
    required int foldersId,
    required int textsId,
  }) async {
    await _apiClient.delete(
      ApiConstants.textsEndpoint,
      data: {'foldersId': foldersId, 'textsId': textsId},
    );
  }

  /// 자료 텍스트(노트) 보관함 이동 (PATCH /texts) - Body: moveFoldersId
  Future<void> moveText({
    required int foldersId,
    required int moveFoldersId,
    required int textsId,
  }) async {
    await _apiClient.patch(
      ApiConstants.textsEndpoint,
      data: {
        'foldersId': foldersId,
        'moveFoldersId': moveFoldersId,
        'textsId': textsId,
      },
    );
  }

  /// 자료 파일 추가 (POST /attachments/files)
  /// Query: foldersIdList
  /// Body: multipart/form-data (file, textContent 파트)
  Future<void> createFile({
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
      'textContent': textContent,
    });
    await _apiClient.post(
      ApiConstants.attachmentsFilesEndpoint,
      queryParameters: {
        'foldersIdList': ListParam(foldersIdList, ListFormat.multi),
      },
      data: formData,
    );
  }

  /// 자료 파일/이미지 보관함 이동 (PATCH /attachments)
  Future<void> moveAttachment({
    required int foldersId,
    required int moveFoldersId,
    required int attachmentsId,
  }) async {
    await _apiClient.patch(
      ApiConstants.attachmentsEndpoint,
      data: {
        'foldersId': foldersId,
        'moveFoldersId': moveFoldersId,
        'attachmentsId': attachmentsId,
      },
    );
  }

  /// 자료 파일 이름 수정 (PATCH /attachments/update)
  Future<void> updateAttachmentFileName({
    required int foldersId,
    required int attachmentsId,
    required String textContent,
    required String fileName,
  }) async {
    await _apiClient.patch(
      ApiConstants.attachmentsUpdateEndpoint,
      data: {
        'foldersId': foldersId,
        'attachmentsId': attachmentsId,
        'textContent': textContent,
        'fileName': fileName,
      },
    );
  }

  /// 자료 파일/이미지 삭제 (DELETE /attachments)
  Future<void> deleteAttachment({required int attachmentsId}) async {
    await _apiClient.delete(
      ApiConstants.attachmentsEndpoint,
      queryParameters: {'attachmentsId': attachmentsId},
    );
  }

  /// 보관함 내부 항목 조회 (링크/노트/파일/이미지)
  Future<PageItemsResponseDto> fetchPageItems({required int foldersId}) async {
    final response = await _apiClient.get(
      ApiConstants.pageItemsEndpoint,
      queryParameters: {'foldersId': foldersId},
    );

    return PageItemsResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// 보관함(폴더) 수정
  Future<void> updateFolder({
    required int foldersId,
    required String name,
    required String memo,
    required String color,
    required int iconIdx,
  }) async {
    await _apiClient.patch(
      ApiConstants.foldersEndpoint,
      data: {
        'foldersId': foldersId,
        'name': name,
        'memo': memo,
        'color': color,
        'iconIdx': iconIdx,
      },
    );
  }

  /// presigned URL 발급 (POST /attachments/presign)
  Future<List<PresignResponseDto>> presignAttachment(
    PresignRequestDto request,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.attachmentsPresignEndpoint,
      data: request.toJson(),
    );
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(PresignResponseDto.fromJson)
          .toList();
    }
    return const [];
  }

  /// S3 직접 PUT 업로드 (인증 헤더 없이 별도 Dio 사용)
  Future<void> uploadToS3({
    required String uploadUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final rawDio = Dio();
    await rawDio.put(
      uploadUrl,
      data: Stream<List<int>>.fromIterable([bytes]),
      options: Options(
        headers: {
          Headers.contentTypeHeader: contentType,
          Headers.contentLengthHeader: bytes.length,
        },
        contentType: contentType,
        responseType: ResponseType.plain,
      ),
    );
  }

  /// 업로드 완료 확인 (POST /attachments/confirm)
  Future<void> confirmAttachment(ConfirmRequestDto request) async {
    await _apiClient.post(
      ApiConstants.attachmentsConfirmEndpoint,
      data: request.toJson(),
    );
  }
}

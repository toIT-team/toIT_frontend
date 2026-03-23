import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../datasources/remote/home_remote_datasource.dart';
import '../models/dto/home_response_dto.dart';
import '../models/dto/link_preview_response_dto.dart';
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
      usersId: ApiConstants.devUserId,
      todayDate: todayDate,
    );

    return response;
  }

  /// 보관함(폴더) 삭제
  Future<void> deleteFolder({required int foldersId}) async {
    await _remoteDatasource.deleteFolder(
      usersId: ApiConstants.devUserId,
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
      usersId: ApiConstants.devUserId,
      foldersId: foldersId,
      name: name,
      memo: memo,
      color: color,
    );
  }

  /// 링크 미리보기 추출 (POST /links/preview)
  Future<LinkPreviewResponseDto> fetchLinkPreview({
    required String linksUrl,
  }) async {
    return _remoteDatasource.fetchLinkPreview(linksUrl: linksUrl);
  }

  /// 자료 링크 추가 (POST /links)
  Future<void> createLink({
    required List<int> foldersIdList,
    required String linksUrl,
    String? linksName,
    String? textContent,
    String? linksThumbnail,
  }) async {
    await _remoteDatasource.createLink(
      usersId: ApiConstants.devUserId,
      foldersIdList: foldersIdList,
      linksUrl: linksUrl,
      linksName: linksName,
      textContent: textContent,
      linksThumbnail: linksThumbnail,
    );
  }

  /// 자료 링크 삭제 (DELETE /links)
  Future<void> deleteLink({
    required int foldersId,
    required int linksId,
  }) async {
    await _remoteDatasource.deleteLink(
      usersId: ApiConstants.devUserId,
      foldersId: foldersId,
      linksId: linksId,
    );
  }

  /// 자료 링크 수정 (PATCH /links/update) - 제목·설명
  Future<void> updateLink({
    required int foldersId,
    required int linksId,
    required String linksName,
    required String textContent,
  }) async {
    await _remoteDatasource.updateLink(
      usersId: ApiConstants.devUserId,
      foldersId: foldersId,
      linksId: linksId,
      linksName: linksName,
      textContent: textContent,
    );
  }

  /// 자료 링크 보관함 이동 (PATCH /links)
  Future<void> moveLink({
    required int foldersId,
    required int moveFoldersId,
    required int linksId,
  }) async {
    await _remoteDatasource.moveLink(
      usersId: ApiConstants.devUserId,
      foldersId: foldersId,
      moveFoldersId: moveFoldersId,
      linksId: linksId,
    );
  }

  /// 자료 텍스트(노트) 추가 (POST /texts)
  Future<void> createText({
    required List<int> foldersIdList,
    required String textContent,
  }) async {
    await _remoteDatasource.createText(
      usersId: ApiConstants.devUserId,
      foldersIdList: foldersIdList,
      textContent: textContent,
    );
  }

  /// 자료 텍스트(노트) 수정 (PATCH /texts/update)
  Future<void> updateText({
    required int foldersId,
    required int textsId,
    required String textContent,
  }) async {
    await _remoteDatasource.updateText(
      usersId: ApiConstants.devUserId,
      foldersId: foldersId,
      textsId: textsId,
      textContent: textContent,
    );
  }

  /// 자료 텍스트(노트) 삭제 (DELETE /texts)
  Future<void> deleteText({
    required int foldersId,
    required int textsId,
  }) async {
    await _remoteDatasource.deleteText(
      usersId: ApiConstants.devUserId,
      foldersId: foldersId,
      textsId: textsId,
    );
  }

  /// 자료 텍스트(노트) 보관함 이동 (PATCH /texts)
  Future<void> moveText({
    required int foldersId,
    required int moveFoldersId,
    required int textsId,
  }) async {
    await _remoteDatasource.moveText(
      usersId: ApiConstants.devUserId,
      foldersId: foldersId,
      moveFoldersId: moveFoldersId,
      textsId: textsId,
    );
  }

  /// 자료 파일 추가 (POST /attachments/files)
  Future<void> createFile({
    required List<int> foldersIdList,
    required String textContent,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    await _remoteDatasource.createFile(
      usersId: ApiConstants.devUserId,
      foldersIdList: foldersIdList,
      textContent: textContent,
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }

  /// 자료 이미지 추가 (POST /attachments/images)
  Future<void> createImage({
    required List<int> foldersIdList,
    required String textContent,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    await _remoteDatasource.createImage(
      usersId: ApiConstants.devUserId,
      foldersIdList: foldersIdList,
      textContent: textContent,
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }

  /// 자료 파일/이미지 보관함 이동 (PATCH /attachments)
  Future<void> moveAttachment({
    required int foldersId,
    required int moveFoldersId,
    required int attachmentsId,
  }) async {
    await _remoteDatasource.moveAttachment(
      usersId: ApiConstants.devUserId,
      foldersId: foldersId,
      moveFoldersId: moveFoldersId,
      attachmentsId: attachmentsId,
    );
  }

  /// 자료 파일/이미지 삭제 (DELETE /attachments)
  Future<void> deleteAttachment({required int attachmentsId}) async {
    await _remoteDatasource.deleteAttachment(
      usersId: ApiConstants.devUserId,
      attachmentsId: attachmentsId,
    );
  }

  /// 보관함 내부 항목 조회 (GET /page/items)
  Future<PageItemsResponseDto> getPageItems({required int foldersId}) async {
    return _remoteDatasource.fetchPageItems(
      usersId: ApiConstants.devUserId,
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
      usersId: ApiConstants.devUserId,
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

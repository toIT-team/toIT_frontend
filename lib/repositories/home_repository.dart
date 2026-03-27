import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
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
  final int _userId;

  const HomeRepository(this._remoteDatasource, this._userId);

  /// 홈 화면 데이터 조회
  Future<HomeResponseDto> fetchHomeData({
    required String todayDate,
  }) async {
    return _remoteDatasource.fetchHomeData(
      usersId: _userId,
      todayDate: todayDate,
    );
  }

  /// 보관함(폴더) 삭제
  Future<void> deleteFolder({required int foldersId}) async {
    await _remoteDatasource.deleteFolder(
      usersId: _userId,
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
      usersId: _userId,
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
      usersId: _userId,
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
      usersId: _userId,
      foldersId: foldersId,
      linksId: linksId,
    );
  }

  /// 자료 링크 수정 (PATCH /links/update)
  Future<void> updateLink({
    required int foldersId,
    required int linksId,
    required String linksName,
    required String textContent,
  }) async {
    await _remoteDatasource.updateLink(
      usersId: _userId,
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
      usersId: _userId,
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
      usersId: _userId,
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
      usersId: _userId,
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
      usersId: _userId,
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
      usersId: _userId,
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
      usersId: _userId,
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
      usersId: _userId,
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
      usersId: _userId,
      foldersId: foldersId,
      moveFoldersId: moveFoldersId,
      attachmentsId: attachmentsId,
    );
  }

  /// 자료 파일/이미지 삭제 (DELETE /attachments)
  Future<void> deleteAttachment({required int attachmentsId}) async {
    await _remoteDatasource.deleteAttachment(
      usersId: _userId,
      attachmentsId: attachmentsId,
    );
  }

  /// 보관함 내부 항목 조회 (GET /page/items)
  Future<PageItemsResponseDto> getPageItems({
    required int foldersId,
  }) async {
    return _remoteDatasource.fetchPageItems(
      usersId: _userId,
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
      usersId: _userId,
      name: name,
      memo: memo,
      color: color,
    );
  }
}

/// HomeRemoteDatasource Provider
final homeRemoteDatasourceProvider =
    Provider<HomeRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRemoteDatasource(apiClient);
});

/// HomeRepository Provider (로그인된 userId 주입)
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDatasource = ref.watch(homeRemoteDatasourceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return HomeRepository(remoteDatasource, userId);
});

/// 보관함 상세 항목 (GET /page/items) - foldersId별 캐시
final pageItemsProvider =
    FutureProvider.family<PageItemsResponseDto, int>((
  ref,
  foldersId,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getPageItems(foldersId: foldersId);
});

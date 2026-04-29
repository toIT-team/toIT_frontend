import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/utils/attachment_upload_utils.dart';
import '../datasources/remote/home_remote_datasource.dart';
import '../models/dto/attachment_confirm_dto.dart';
import '../models/dto/attachment_presign_dto.dart';
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
  Future<HomeResponseDto> fetchHomeData({required String todayDate}) async {
    return _remoteDatasource.fetchHomeData(todayDate: todayDate);
  }

  /// 보관함(폴더) 삭제
  Future<void> deleteFolder({required int foldersId}) async {
    await _remoteDatasource.deleteFolder(foldersId: foldersId);
  }

  /// 보관함(폴더) 수정
  Future<void> updateFolder({
    required int foldersId,
    required String name,
    required String memo,
    required String color,
    required int iconIdx,
  }) async {
    await _remoteDatasource.updateFolder(
      foldersId: foldersId,
      name: name,
      memo: memo,
      color: color,
      iconIdx: iconIdx,
    );
  }

  /// 보관함 즐겨찾기 토글
  Future<bool> toggleFolderFavorite({
    required int foldersId,
    required bool isFavorite,
  }) async {
    return _remoteDatasource.toggleFolderFavorite(
      foldersId: foldersId,
      isFavorite: isFavorite,
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
    await _remoteDatasource.deleteLink(foldersId: foldersId, linksId: linksId);
  }

  /// 자료 링크 수정 (PATCH /links/update)
  Future<void> updateLink({
    required int foldersId,
    required int linksId,
    required String linksName,
    required String textContent,
  }) async {
    await _remoteDatasource.updateLink(
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
    await _remoteDatasource.deleteText(foldersId: foldersId, textsId: textsId);
  }

  /// 자료 텍스트(노트) 보관함 이동 (PATCH /texts)
  Future<void> moveText({
    required int foldersId,
    required int moveFoldersId,
    required int textsId,
  }) async {
    await _remoteDatasource.moveText(
      foldersId: foldersId,
      moveFoldersId: moveFoldersId,
      textsId: textsId,
    );
  }

  /// 자료 파일 추가 (presign → S3 PUT → confirm)
  /// 기존 multipart 단일 호출을 presigned URL 기반 3단계로 교체
  Future<List<ConfirmResponseItem>> createFile({
    required List<int> foldersIdList,
    required String textContent,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    return _uploadViaPresign(
      foldersIdList: foldersIdList,
      textContent: textContent,
      bytes: fileBytes,
      fileName: fileName,
      attachmentsType: AttachmentsType.file,
    );
  }

  /// 자료 이미지 추가 (presign → S3 PUT → confirm) - 단일
  Future<List<ConfirmResponseItem>> createImage({
    required List<int> foldersIdList,
    required String textContent,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    return _uploadViaPresign(
      foldersIdList: foldersIdList,
      textContent: textContent,
      bytes: imageBytes,
      fileName: fileName,
      attachmentsType: AttachmentsType.image,
    );
  }

  /// 자료 이미지 배치 추가 (presign 1회 → S3 PUT × N → confirm 1회)
  Future<List<ConfirmResponseItem>> createImages({
    required List<int> foldersIdList,
    required String textContent,
    required List<({List<int> bytes, String fileName})> images,
  }) async {
    // 1. 각 이미지 메타 준비
    final payloads = <Uint8List>[];
    final contentTypes = <String>[];
    final dimensionsList = <ImageDimensions?>[];

    for (final img in images) {
      final raw = img.bytes is Uint8List
          ? img.bytes as Uint8List
          : Uint8List.fromList(img.bytes);
      final payload = await compressImageForUpload(raw, img.fileName);
      payloads.add(payload);
      contentTypes.add(resolveContentType(img.fileName));
      dimensionsList.add(await readImageDimensions(payload));
    }

    // 2. presign 1회 (전체 이미지)
    final presignedList = await _remoteDatasource.presignAttachment(
      PresignRequestDto(
        foldersIdList: foldersIdList,
        attachmentsType: AttachmentsType.image,
        textContent: textContent,
        files: [
          for (int i = 0; i < images.length; i++)
            PresignFileDto(
              contentType: contentTypes[i],
              fileName: images[i].fileName,
              fileSize: payloads[i].length,
              width: dimensionsList[i]?.width,
              height: dimensionsList[i]?.height,
            ),
        ],
      ),
    );

    if (presignedList.length != images.length) {
      throw Exception('presign 응답 수 불일치: ${presignedList.length}/${images.length}');
    }

    // 3. S3 PUT 병렬 업로드
    await Future.wait([
      for (int i = 0; i < images.length; i++)
        _remoteDatasource.uploadToS3(
          uploadUrl: presignedList[i].uploadUrl,
          bytes: payloads[i],
          contentType: contentTypes[i],
        ),
    ]);

    // 4. confirm 1회 (전체 이미지)
    return _remoteDatasource.confirmAttachment(
      ConfirmRequestDto(
        foldersIdList: foldersIdList,
        attachmentsType: AttachmentsType.image,
        textContent: textContent,
        files: [
          for (int i = 0; i < images.length; i++)
            ConfirmFileDto(
              objectKey: presignedList[i].objectKey,
              fileName: images[i].fileName,
              contentType: contentTypes[i],
              fileSize: payloads[i].length,
              width: dimensionsList[i]?.width,
              height: dimensionsList[i]?.height,
            ),
        ],
      ),
    );
  }

  /// presign → S3 PUT → confirm 3단계 업로드 공통 로직
  Future<List<ConfirmResponseItem>> _uploadViaPresign({
    required List<int> foldersIdList,
    required String textContent,
    required List<int> bytes,
    required String fileName,
    required String attachmentsType,
  }) async {
    final raw = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final payload = attachmentsType == AttachmentsType.image
        ? await compressImageForUpload(raw, fileName)
        : raw;
    final fileSize = payload.length;
    final contentType = resolveContentType(fileName);
    // 백엔드가 textContent null 처리에서 NPE를 내는 경우가 있어 빈 문자열도 명시 전달한다.
    final normalizedTextContent = textContent;

    int? width;
    int? height;
    if (attachmentsType == AttachmentsType.image) {
      final dimensions = await readImageDimensions(payload);
      width = dimensions?.width;
      height = dimensions?.height;
    }

    final presignedFiles = await _remoteDatasource.presignAttachment(
      PresignRequestDto(
        foldersIdList: foldersIdList,
        attachmentsType: attachmentsType,
        files: [
          PresignFileDto(
            contentType: contentType,
            fileName: fileName,
            fileSize: fileSize,
            width: width,
            height: height,
          ),
        ],
        textContent: normalizedTextContent,
      ),
    );
    if (presignedFiles.isEmpty) {
      throw Exception('presign 응답이 비어 있습니다.');
    }
    final presign = presignedFiles.first;
    // if (kDebugMode) {
      // debugPrint(
        // '[upload] presign ok type=$attachmentsType '
        // 'objectKey=${presign.objectKey} size=$fileSize',
      // );
    // }

    await _remoteDatasource.uploadToS3(
      uploadUrl: presign.uploadUrl,
      bytes: payload,
      contentType: contentType,
    );

    final confirmed = await _remoteDatasource.confirmAttachment(
      ConfirmRequestDto(
        foldersIdList: foldersIdList,
        attachmentsType: attachmentsType,
        files: [
          ConfirmFileDto(
            objectKey: presign.objectKey,
            fileName: fileName,
            contentType: contentType,
            fileSize: fileSize,
            width: width,
            height: height,
          ),
        ],
        textContent: normalizedTextContent,
      ),
    );
    // if (kDebugMode) {
      // debugPrint(
        // '[upload] confirm ok count=${confirmed.length} '
        // 'objectKey=${presign.objectKey}',
      // );
    // }
    return confirmed;
  }

  /// 자료 파일/이미지 보관함 이동 (PATCH /attachments)
  Future<void> moveAttachment({
    required int foldersId,
    required int moveFoldersId,
    required int attachmentsId,
  }) async {
    await _remoteDatasource.moveAttachment(
      foldersId: foldersId,
      moveFoldersId: moveFoldersId,
      attachmentsId: attachmentsId,
    );
  }

  /// 자료 파일 이름 수정 (PATCH /attachments/update)
  Future<void> updateAttachmentFileName({
    required int foldersId,
    required int attachmentsId,
    required String textContent,
    required String fileName,
  }) async {
    await _remoteDatasource.updateAttachmentFileName(
      foldersId: foldersId,
      attachmentsId: attachmentsId,
      textContent: textContent,
      fileName: fileName,
    );
  }

  /// 자료 파일/이미지 삭제 (DELETE /attachments)
  Future<void> deleteAttachment({required int attachmentsId}) async {
    await _remoteDatasource.deleteAttachment(attachmentsId: attachmentsId);
  }

  /// 보관함 내부 항목 조회 (GET /page/items)
  Future<PageItemsResponseDto> getPageItems({required int foldersId}) async {
    return _remoteDatasource.fetchPageItems(foldersId: foldersId);
  }

  /// 보관함(폴더) 생성
  Future<FolderDto> createFolder({
    required String name,
    required String memo,
    required String color,
    required int iconIdx,
  }) async {
    return _remoteDatasource.createFolder(
      name: name,
      memo: memo,
      color: color,
      iconIdx: iconIdx,
    );
  }
}

/// HomeRemoteDatasource Provider
final homeRemoteDatasourceProvider = Provider<HomeRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRemoteDatasource(apiClient);
});

/// HomeRepository Provider (로그인된 userId 주입)
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

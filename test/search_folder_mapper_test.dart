import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:toit/core/utils/search_folder_mapper.dart';
import 'package:toit/models/dto/search_response_dto.dart';
import 'package:toit/models/home/folder_item.dart';

void main() {
  group('folderItemFromSearchFolderDto', () {
    test('홈에 없는 폴더는 검색 DTO의 isFavorite를 반영한다', () {
      const dto = SearchFolderItemDto(
        foldersId: 99,
        name: '원격',
        isFavorite: true,
        iconIdx: 0,
      );
      final item = folderItemFromSearchFolderDto(dto, <FolderItem>[]);
      expect(item.isFavorite, isTrue);
      expect(item.foldersId, 99);
    });

    test('홈에 있는 폴더도 검색 응답의 isFavorite를 우선한다', () {
      final home = FolderItem(
        foldersId: 1,
        title: '로컬',
        memo: '',
        countText: '3개',
        colorIndex: 2,
        iconIndex: 1,
        isDefault: false,
        isFavorite: false,
        accentColor: Colors.blue,
      );
      const dto = SearchFolderItemDto(
        foldersId: 1,
        name: '로컬',
        isFavorite: true,
        iconIdx: 1,
      );
      final item = folderItemFromSearchFolderDto(dto, [home]);
      expect(item.isFavorite, isTrue);
      expect(item.countText, '3개');
    });
  });
}

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder_item.freezed.dart';
part 'folder_item.g.dart';

/// 폴더 카드 모델 (홈 화면용)
@freezed
class FolderItem with _$FolderItem {
  const factory FolderItem({
    /// 폴더 ID
    @Default(0) int foldersId,

    /// 폴더 제목
    required String title,

    /// 메모
    @Default('') String memo,

    /// 항목 개수 텍스트 (예: "2개")
    required String countText,

    /// 색상 인덱스 (folderColors 기준)
    @Default(5) int colorIndex,

    /// 강조 색상 (JSON 제외)
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(Color(0xFFA2CAFF))
    Color accentColor,
  }) = _FolderItem;

  factory FolderItem.fromJson(Map<String, dynamic> json) =>
      _$FolderItemFromJson(json);
}

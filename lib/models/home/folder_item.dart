import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder_item.freezed.dart';
part 'folder_item.g.dart';

/// 폴더 카드 모델 (홈 화면용)
@freezed
class FolderItem with _$FolderItem {
  const factory FolderItem({
    /// 폴더 제목
    required String title,

    /// 항목 개수 텍스트 (예: "2개")
    required String countText,

    /// 강조 색상 (JSON 제외)
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(Color(0xFFA2CAFF))
    Color accentColor,
  }) = _FolderItem;

  factory FolderItem.fromJson(Map<String, dynamic> json) =>
      _$FolderItemFromJson(json);
}

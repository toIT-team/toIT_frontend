import 'package:flutter/material.dart';

import '../../../core/constants/setting_layout_tokens.dart';

/// 보관함(폴더) 섹션
///
/// [isEditable] true (추가·수정 폼):
///   - 미선택: "보관함 선택" (회색) + (+), (+) 또는 제목 행 탭 시 [onTap]
///   - 선택됨: 이름 (검정) + (×), 제목 행 탭은 [onTap], (×)는 [onClearFolderTap]
/// [isEditable] false (일정 상세):
///   - 보관함 이름 + (>) 화살표, 행 전체가 [onTap]
class EventFolderSection extends StatelessWidget {
  const EventFolderSection({
    super.key,
    this.folderName,
    this.isEditable = false,
    this.onTap,
    this.onClearFolderTap,
  });

  /// 보관함 이름 (null이면 미선택 상태)
  final String? folderName;
  final bool isEditable;
  /// 보관함 선택 시트를 열거나(폼) 상세 이동 등
  final VoidCallback? onTap;
  /// 편집 모드에서 연결 해제 (×) 전용
  final VoidCallback? onClearFolderTap;

  bool get _hasFolder =>
      folderName != null && folderName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!isEditable) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Expanded(
              child: Text(
                _hasFolder ? folderName! : '보관함 선택',
                style: TextStyle(
                  fontSize: SettingLayout1Tokens.fontSize,
                  color: _hasFolder ? Colors.black : Colors.grey,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: SettingLayout1Tokens.trailingIconSize,
            ),
          ],
        ),
      );
    }

    final trailingColor = Colors.grey[400];
    final iconSize = SettingLayout1Tokens.trailingIconSize;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              _hasFolder ? folderName! : '보관함 선택',
              style: TextStyle(
                fontSize: SettingLayout1Tokens.fontSize,
                color: _hasFolder ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _hasFolder ? onClearFolderTap : onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              _hasFolder ? Icons.close : Icons.add,
              color: trailingColor,
              size: iconSize,
            ),
          ),
        ),
      ],
    );
  }
}

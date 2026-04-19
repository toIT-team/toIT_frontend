import 'package:flutter/material.dart';

import '../../../core/constants/setting_layout_tokens.dart';

/// 보관함(폴더) 섹션
///
/// [isEditable] true (수정 모드):
///   - 보관함 미선택: "보관함 선택" (회색) + (+) 아이콘
///   - 보관함 선택됨: 보관함 이름 (검정) + (+) 아이콘
/// [isEditable] false (일정 상세 모드):
///   - 보관함 이름 (검정) + (>) 화살표 아이콘
class EventFolderSection extends StatelessWidget {
  const EventFolderSection({
    super.key,
    this.folderName,
    this.isEditable = false,
    this.onTap,
  });

  /// 보관함 이름 (null이면 미선택 상태)
  final String? folderName;
  final bool isEditable;
  final VoidCallback? onTap;

  /// 보관함이 선택되었는지 여부
  bool get _hasFolder =>
      folderName != null && folderName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
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
                color: _hasFolder
                    ? Colors.black
                    : Colors.grey,
              ),
            ),
          ),
          Icon(
            isEditable ? Icons.add : Icons.chevron_right,
            color: Colors.grey[400],
            size: SettingLayout1Tokens.trailingIconSize,
          ),
        ],
      ),
    );
  }
}

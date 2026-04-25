import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _hasFolder ? folderName! : '보관함 선택',
                style: TextStyle(
                  fontSize: SettingLayout1Tokens.fontSize,
                  color: _hasFolder ? AppColors.gray900 : AppColors.gray600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.gray400,
              size: SettingLayout1Tokens.trailingIconSize,
            ),
          ],
        ),
      );
    }

    const trailingColor = AppColors.gray400;
    final iconSize = SettingLayout1Tokens.trailingIconSize;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              _hasFolder ? folderName! : '보관함 선택',
              style: TextStyle(
                fontSize: SettingLayout1Tokens.fontSize,
                color: _hasFolder ? AppColors.gray900 : AppColors.gray600,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _hasFolder ? onClearFolderTap : onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            // 상단 패딩 없음: 선행 SVG(24px)와 첫 텍스트 줄 상단을 맞춤
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
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

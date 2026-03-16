import 'package:flutter/material.dart';

import '../../../core/constants/setting_layout_tokens.dart';
import '../common/custom_toggle.dart';

/// 알림 섹션
///
/// 설정 레이아웃 1 구조: 아이콘 - 타이틀 - 토글
/// 토글 off → on 시 바텀시트가 올라와 옵션 선택
/// 토글 on 상태에서 텍스트 탭 시 바텀시트로 옵션 변경
class EventAlarmSection extends StatelessWidget {
  const EventAlarmSection({
    super.key,
    this.alarmText,
    this.alarmEnabled = false,
    this.isEditable = false,
    this.onAddTap,
    this.onToggleChanged,
  });

  /// 알림 설정 시 표시 텍스트 (예: "10분 전")
  final String? alarmText;

  /// 알림 활성화 여부
  final bool alarmEnabled;

  final bool isEditable;

  /// 텍스트 탭 시 (알림 on 상태에서 옵션 변경용 바텀시트)
  final VoidCallback? onAddTap;

  /// 토글 변경 시 (true: on + 바텀시트, false: off)
  final ValueChanged<bool>? onToggleChanged;

  @override
  Widget build(BuildContext context) {
    final displayText = alarmEnabled && alarmText != null && alarmText!.isNotEmpty
        ? alarmText!
        : '알림';

    final trailing = isEditable && onToggleChanged != null
        ? CustomToggle(
            value: alarmEnabled,
            onChanged: onToggleChanged,
          )
        : null;

    final textWidget = Text(
      displayText,
      style: TextStyle(
        fontSize: SettingLayout1Tokens.fontSize,
        color: alarmEnabled ? Colors.black : Colors.grey,
      ),
    );

    final textChild = isEditable && alarmEnabled && onAddTap != null
        ? GestureDetector(
            onTap: onAddTap,
            behavior: HitTestBehavior.opaque,
            child: textWidget,
          )
        : textWidget;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: textChild),
        if (trailing != null) trailing,
      ],
    );
  }
}

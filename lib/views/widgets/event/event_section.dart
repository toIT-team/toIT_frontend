import 'package:flutter/material.dart';

import '../../../core/constants/setting_layout_tokens.dart';

/// 이벤트 섹션 레이아웃 상수
///
/// 설정 레이아웃 1 토큰을 사용하여 보관함/위치/알림/메모 등
/// 아이콘-타이틀-아이콘 구조의 일관된 크기 유지
class EventSectionConstants {
  EventSectionConstants._();

  static const horizontalPadding = SettingLayout1Tokens.horizontalPadding;
  static const verticalPadding = SettingLayout1Tokens.verticalPadding;
  static const iconSize = SettingLayout1Tokens.leadingIconSize;
  static const iconGap = SettingLayout1Tokens.iconTitleGap;
}

/// 이벤트 섹션 아이템 데이터
class EventSectionItem {
  const EventSectionItem({
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Widget child;
}

/// 이벤트 섹션 위젯 (아이콘 + 컨텐츠)
class EventSection extends StatelessWidget {
  const EventSection({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: EventSectionConstants.horizontalPadding,
        vertical: EventSectionConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: EventSectionConstants.iconSize,
          ),
          const SizedBox(width: EventSectionConstants.iconGap),
          Expanded(child: child),
        ],
      ),
    );
  }
}

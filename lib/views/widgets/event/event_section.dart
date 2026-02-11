import 'package:flutter/material.dart';

/// 이벤트 섹션 레이아웃 상수
class EventSectionConstants {
  EventSectionConstants._();

  static const horizontalPadding = 20.0;
  static const verticalPadding = 16.0;
  static const iconSize = 24.0;
  static const iconGap = 16.0;
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

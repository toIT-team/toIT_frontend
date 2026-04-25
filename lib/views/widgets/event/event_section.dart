import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/setting_layout_tokens.dart';

/// 이벤트 섹션 레이아웃 상수
///
/// 설정 레이아웃 1 토큰을 사용하여 보관함/위치/알림/메모 등
/// 아이콘-타이틀-아이콘 구조의 일관된 크기 유지
class EventSectionConstants {
  EventSectionConstants._();

  static const horizontalPadding =
      SettingLayout1Tokens.horizontalPadding;
  static const verticalPadding = SettingLayout1Tokens.verticalPadding;
  static const iconSize = SettingLayout1Tokens.leadingIconSize;
  static const iconGap = SettingLayout1Tokens.iconTitleGap;
}

/// 이벤트 섹션 아이템 데이터
class EventSectionItem {
  const EventSectionItem({
    required this.iconSvgAsset,
    required this.iconColor,
    required this.child,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
  });

  final String iconSvgAsset;
  final Color iconColor;
  final Widget child;

  /// 단일 행(알림 등)은 [center]로 선행 아이콘과 세로 중앙을 맞춘다.
  /// 시간 블록처럼 높은 본문은 [start] 유지.
  final CrossAxisAlignment rowCrossAxisAlignment;
}

/// 이벤트 섹션 위젯 (SVG 리드 아이콘 + 컨텐츠)
///
/// Material [Icon] 폴백은 두지 않는다. 에셋만 표시해 디자인과 불일치를 막는다.
class EventSection extends StatelessWidget {
  const EventSection({
    super.key,
    required this.iconSvgAsset,
    required this.iconColor,
    required this.child,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
  });

  final String iconSvgAsset;
  final Color iconColor;
  final Widget child;

  /// [center]: 토글 등 본문 높이 > 아이콘일 때 선행 SVG와 세로 중앙 정렬
  final CrossAxisAlignment rowCrossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: EventSectionConstants.horizontalPadding,
        vertical: EventSectionConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: rowCrossAxisAlignment,
        children: [
          _buildLeading(),
          const SizedBox(width: EventSectionConstants.iconGap),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildLeading() {
    final size = EventSectionConstants.iconSize;
    // stroke 위주 SVG는 srcIn 색 보정 시 형태가 깨지거나 달라 보일 수 있음.
    // 에셋에 정의된 stroke 색을 그대로 사용한다.
    return SvgPicture.asset(
      iconSvgAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

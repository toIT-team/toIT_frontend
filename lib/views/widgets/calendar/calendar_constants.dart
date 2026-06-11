import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 캘린더 그리드 레이아웃 상수
const double kCalendarCellVerticalMargin = 1.0;
const double kCalendarDateHeaderHeight = 32.0;
const double kCalendarEventChipHeight = 16.0;
const double kCalendarEventChipTopPadding = 2.0;
const double kCalendarEventSlotHeight = 18.0;
const int kCalendarMaxVisibleEvents = 3;
const double kCalendarEventAreaHeight =
    kCalendarMaxVisibleEvents * kCalendarEventSlotHeight;
const double kCalendarWeekEventLayerTop =
    kCalendarCellVerticalMargin + kCalendarDateHeaderHeight;
/// +N 텍스트(fontSize 10) + 상단 여백
const double kCalendarOverflowAreaHeight = 14.0;
const double kCalendarCellBottomPadding = 4.0;
const double kCalendarWeekRowHeight =
    kCalendarCellVerticalMargin * 2 +
    kCalendarDateHeaderHeight +
    kCalendarEventAreaHeight +
    kCalendarOverflowAreaHeight +
    kCalendarCellBottomPadding;

/// 업로드 배너 등 고정 inset용 최소값
const double kCalendarBottomNavReserve = 84.0;

const double kCalendarNavBarContentHeight = 52.0;
const double kCalendarNavBarTopPadding = 8.0;
const double kCalendarScrollBottomExtra = 20.0;

/// 스크롤 끝에서 하단 네비·시스템 inset을 피하기 위한 padding
double calendarScrollBottomPadding(BuildContext context) {
  final mq = MediaQuery.of(context);
  final platform = Theme.of(context).platform;
  final systemBottom = math.max(
    math.max(mq.viewPadding.bottom, mq.padding.bottom),
    mq.systemGestureInsets.bottom,
  );
  final navGap = platform == TargetPlatform.android ? 12.0 : 8.0;

  return systemBottom +
      navGap +
      kCalendarNavBarTopPadding +
      kCalendarNavBarContentHeight +
      kCalendarScrollBottomExtra;
}

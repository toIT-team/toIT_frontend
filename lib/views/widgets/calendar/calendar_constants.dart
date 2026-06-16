import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 캘린더 그리드 레이아웃 상수
const double kCalendarCellVerticalMargin = 1.0;
const double kCalendarDateHeaderHeight = 32.0;
const double kCalendarEventChipHeight = 16.0;
const double kCalendarEventChipTopPadding = 2.0;
const double kCalendarEventSlotHeight = 18.0;
const double kCalendarWeekEventLayerTop =
    kCalendarCellVerticalMargin + kCalendarDateHeaderHeight;
const double kCalendarCellBottomPadding = 4.0;

// ── 칩 표시 개수 제한 + '+N' 오버플로우 기능 (현재 무제한 표시로 비활성화) ──
// 다시 제한을 두려면 아래 상수를 살리고, 컨트롤러/그리드/셀의 오버플로우 주석을
// 함께 해제한다.
// const int kCalendarMaxVisibleEvents = 3;
// /// +N 텍스트(fontSize 10) + 상단 여백
// const double kCalendarOverflowAreaHeight = 14.0;

/// 이벤트 수와 무관하게 기본으로 확보하는 칩 줄 수.
/// 이벤트가 적어도 셀 높이를 일정하게 유지하고, 이 줄 수를 넘는 주에서만
/// 셀이 점점 늘어나도록 하는 기준값.
const int kCalendarMinEventRows = 4;

/// 칩 줄 수에 따른 이벤트 영역 높이를 계산한다.
double calendarEventAreaHeight(int eventRows) =>
    eventRows * kCalendarEventSlotHeight;

/// 칩 줄 수에 따른 주(週) 행 높이를 계산한다.
/// 이벤트 수가 늘어나면 셀 높이도 함께 늘어나도록 동적으로 산출한다.
double calendarWeekRowHeight(int eventRows) =>
    kCalendarCellVerticalMargin * 2 +
    kCalendarDateHeaderHeight +
    calendarEventAreaHeight(eventRows) +
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

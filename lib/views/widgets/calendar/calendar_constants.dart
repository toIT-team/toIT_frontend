import 'dart:math' as math;

import 'package:flutter/material.dart';

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

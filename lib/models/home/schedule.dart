import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

/// 일정 모델 (홈 화면용)
@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    /// 일정 제목
    required String title,

    /// 시간 범위 텍스트 (예: "오후10:00 - 오후11:00")
    required String timeRangeText,

    /// 일정 시간 표시 (예: "30분 전", "오늘 마감")
    required String scheduleTime,

    /// 강조 색상 (JSON 제외)
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(Color(0xFF4285F4))
    Color accentColor,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
}

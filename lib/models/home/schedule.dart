import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

/// 일정 모델 (홈 화면용)
@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    /// 서버 일정 ID (상세 화면 이동용)
    @Default(0) int schedulesId,

    /// 일정 제목
    required String title,

    /// 시간 범위 텍스트 (예: "오후10:00 - 오후11:00")
    required String timeRangeText,

    /// 일정 시간 표시 (예: "30분 전", "오늘 마감")
    required String scheduleTime,

    /// 강조 색상 (JSON 제외)
    @Default(Color(0xFF4285F4))
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: false, includeToJson: false)
    Color accentColor,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
}

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event.freezed.dart';
part 'calendar_event.g.dart';

/// 캘린더 일정 모델
@freezed
class CalendarEvent with _$CalendarEvent {
  const CalendarEvent._();

  const factory CalendarEvent({
    /// 클라이언트 식별용 ID (백엔드 ID 또는 자동 생성)
    required String id,

    /// 사용자 ID
    required int usersId,

    /// 일정 제목
    required String title,

    /// 시작 날짜 (YYYY-MM-DD 형식)
    @JsonKey(name: 'startAt') required String startAt,

    /// 종료 날짜 (YYYY-MM-DD 형식)
    @JsonKey(name: 'endAt') required String endAt,

    /// 시작 시간 (HH:mm 형식, nullable)
    String? startTime,

    /// 종료 시간 (HH:mm 형식, nullable)
    String? endTime,

    /// 시간 설정 여부
    @Default(false) bool timeSetting,

    /// 보관함(폴더) 이름
    String? folderName,

    /// 생성 일시
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? createdAt,

    /// 표시 색상 (클라이언트 전용, JSON 제외)
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(Color(0xFF4285F4))
    Color color,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);

  /// 시작 날짜를 DateTime으로 변환
  DateTime get startDate => DateTime.parse(startAt);

  /// 종료 날짜를 DateTime으로 변환
  DateTime get endDate => DateTime.parse(endAt);

  /// 일정이 특정 날짜에 해당하는지 확인
  bool occursOnDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final eventStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final eventEnd = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(const Duration(days: 1));

    return eventStart.isBefore(dayEnd) && eventEnd.isAfter(dayStart);
  }

  /// 여러 날에 걸친 일정인지 확인
  bool get isMultiDay {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return start != end;
  }

  /// 일정 기간 (일 수)
  int get durationInDays {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.difference(start).inDays + 1;
  }

  /// 시간 포함 시작 DateTime
  DateTime? get startDateTime {
    if (!timeSetting || startTime == null) return null;
    final parts = startTime!.split(':');
    return DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// 시간 포함 종료 DateTime
  DateTime? get endDateTime {
    if (!timeSetting || endTime == null) return null;
    final parts = endTime!.split(':');
    return DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}

/// JSON에서 DateTime으로 변환
DateTime? _dateTimeFromJson(String? value) =>
    value != null ? DateTime.parse(value) : null;

/// DateTime을 JSON으로 변환
String? _dateTimeToJson(DateTime? dateTime) => dateTime?.toIso8601String();

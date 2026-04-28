import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/constants/event_color_tokens.dart';
import '../models/calendar/calendar_event.dart';
import '../models/schedule/schedule_response.dart';

/// 일정 API 클라이언트
class ScheduleApiClient {
  ScheduleApiClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// 선택된 날짜의 일정 조회 (바텀시트용)
  Future<List<CalendarEvent>> getSelectedDaySchedules({
    required DateTime selectedDay,
  }) async {
    final selectedDayStr = _formatDate(selectedDay);

    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}/page/schedules/selected',
      queryParameters: {'selectedDay': selectedDayStr},
    );

    if (response.data == null) return [];

    final selectedResponse = SelectedSchedulesResponse.fromJson(response.data!);
    return selectedResponse.schedulesResponses
        .map((item) => _toCalendarEventFromSelected(item, selectedDayStr))
        .toList();
  }

  /// 일정 상세 조회
  /// GET /page/schedules/detail?schedulesId=
  Future<ScheduleDetailResponse> getScheduleDetail({
    required int schedulesId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}/page/schedules/detail',
      queryParameters: {'schedulesId': schedulesId},
    );

    if (response.data == null) {
      throw Exception('일정 상세 응답이 비어있습니다.');
    }

    return ScheduleDetailResponse.fromJson(response.data!);
  }

  /// startDate ~ endDate 범위의 일정 검색
  Future<List<CalendarEvent>> searchSchedules({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startStr = _formatDate(startDate);
    final endStr = _formatDate(endDate);

    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}/page/schedules/search',
      queryParameters: {'startDate': startStr, 'endDate': endStr},
    );

    if (response.data == null) return [];

    final searchResponse = ScheduleSearchResponse.fromJson(response.data!);
    return searchResponse.schedulesResponses.map(_toCalendarEvent).toList();
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// 시간을 HH:mm:ss 형식으로 변환
  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '09:00:00';
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
    }
    return '09:00:00';
  }

  /// 일정 생성
  Future<CalendarEvent> createSchedule({
    required String title,
    required String appColor,
    required bool timeSetting,
    required DateTime startDate,
    required DateTime endDate,
    String? startTime,
    String? endTime,
    String? memo,
    required bool alarmState,
    int alarmOffsetMinutes = 0,
    int? foldersId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'appColor': appColor,
      'foldersId': foldersId,
      'timeSetting': timeSetting,
      'startDate': _formatDate(startDate),
      'startTime': timeSetting ? _formatTime(startTime) : null,
      'endDate': _formatDate(endDate),
      'endTime': timeSetting ? _formatTime(endTime) : null,
      'memo': memo ?? '',
      'alarmState': alarmState,
      'alarmOffsetMinutes': alarmOffsetMinutes,
    };

    debugPrint('[일정 추가 API] Request: POST ${ApiConstants.baseUrl}/schedules');
    debugPrint('[일정 추가 API] Request body: $body');

    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}/schedules',
      data: body,
    );

    debugPrint('[일정 추가 API] Response status: ${response.statusCode}');
    debugPrint('[일정 추가 API] Response data: ${response.data}');

    if (response.data == null) {
      debugPrint('[일정 추가 API] Error: 응답 데이터가 비어있습니다.');
      throw Exception('일정 생성 응답이 비어있습니다.');
    }

    final item = ScheduleItemResponse.fromJson(response.data!);
    final color = EventColorTokens.fromToken(item.appColor ?? appColor);
    return CalendarEvent(
      id: item.schedulesId.toString(),
      title: item.title,
      startAt: _formatDate(startDate),
      endAt: _formatDate(endDate),
      startTime: timeSetting ? startTime : null,
      endTime: timeSetting ? endTime : null,
      timeSetting: timeSetting,
      color: color,
    );
  }

  /// 일정 수정
  /// PATCH /schedules
  Future<CalendarEvent> updateSchedule({
    required int schedulesId,
    required String title,
    required String appColor,
    required bool timeSetting,
    required DateTime startDate,
    required DateTime endDate,
    String? startTime,
    String? endTime,
    String? memo,
    required bool alarmState,
    int alarmOffsetMinutes = 0,
    int? foldersId,
  }) async {
    final body = <String, dynamic>{
      'schedulesId': schedulesId,
      'title': title,
      'appColor': appColor,
      'foldersId': foldersId,
      'timeSetting': timeSetting,
      'startDate': _formatDate(startDate),
      'endDate': _formatDate(endDate),
      'startTime': timeSetting ? _formatTime(startTime) : null,
      'endTime': timeSetting ? _formatTime(endTime) : null,
      'memo': memo ?? '',
      'alarmState': alarmState,
      'alarmOffsetMinutes': alarmOffsetMinutes,
    };

    print('[일정 수정 API] Request: PATCH ${ApiConstants.baseUrl}/schedules');
    print('[일정 수정 API] Request body: $body');

    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}/schedules',
      data: body,
    );

    print('[일정 수정 API] Response status: ${response.statusCode}');
    print('[일정 수정 API] Response data: ${response.data}');

    if (response.data == null) {
      print('[일정 수정 API] Error: 응답 데이터가 비어있습니다.');
      throw Exception('일정 수정 응답이 비어있습니다.');
    }

    final item = ScheduleItemResponse.fromJson(response.data!);
    final color = EventColorTokens.fromToken(item.appColor ?? appColor);
    return CalendarEvent(
      id: item.schedulesId.toString(),
      title: item.title,
      startAt: _formatDate(startDate),
      endAt: _formatDate(endDate),
      startTime: timeSetting ? startTime : null,
      endTime: timeSetting ? endTime : null,
      timeSetting: timeSetting,
      color: color,
    );
  }

  /// 일정 삭제
  /// 성공 시 200, 실패 시 404/500 등
  Future<void> deleteSchedule({required int schedulesId}) async {
    final body = {'schedulesId': schedulesId};
    // TODO: 개발 단계 - 디버그 로그. 운영 시 제거 또는 레벨 조정
    debugPrint('[일정 삭제 API] DELETE ${ApiConstants.baseUrl}/schedules');
    debugPrint('[일정 삭제 API] Request body: $body');

    final response = await _dio.delete<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}/schedules',
      data: body,
    );

    debugPrint('[일정 삭제 API] Response: ${response.statusCode} ${response.data}');
  }

  CalendarEvent _toCalendarEvent(ScheduleItemResponse item) {
    final color = EventColorTokens.fromToken(item.appColor);
    return CalendarEvent(
      id: item.schedulesId.toString(),
      title: item.title,
      startAt: item.startDate,
      endAt: item.endDate,
      timeSetting: false,
      color: color,
    );
  }

  /// HH:mm:ss → HH:mm 변환 이부분은 백엔드에서 수정할 경우 삭제해도 될 것으로 보이긴함.
  String? _toHhMm(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return null;
  }

  CalendarEvent _toCalendarEventFromSelected(
    SelectedScheduleItemResponse item,
    String selectedDayStr,
  ) {
    final color = EventColorTokens.fromToken(item.appColor);
    final hasTime = item.startTime != null && item.endTime != null;
    final startAt =
        item.startDate.isNotEmpty ? item.startDate : selectedDayStr;
    // endDate가 없는 응답은 "하루 내 시간 범위"로 간주해야 하므로 빈 값 유지
    // (UI에서 날짜 없이 시간만 노출).
    final endAt = item.endDate;
    return CalendarEvent(
      id: item.schedulesId.toString(),
      title: item.title,
      startAt: startAt,
      endAt: endAt,
      startTime: _toHhMm(item.startTime),
      endTime: _toHhMm(item.endTime),
      timeSetting: hasTime,
      color: color,
    );
  }
}

/// ScheduleApiClient Provider
/// ApiClient의 인증 Dio를 공유하여 Bearer 토큰 자동 첨부
final scheduleApiClientProvider = Provider<ScheduleApiClient>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScheduleApiClient(dio: apiClient.dio);
});

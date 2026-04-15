import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_controller.dart';
import '../services/auth_service.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/event_color_tokens.dart';
import '../models/dto/home_response_dto.dart';
import '../models/home/folder_item.dart';
import '../models/home/schedule.dart';
import '../repositories/home_repository.dart';

part 'home_controller.freezed.dart';

/// 홈 화면 상태
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    /// 사용자 이름
    @Default('') String userName,

    /// 오늘 일정 개수
    @Default(0) int todayScheduleCount,

    /// 오늘 일정 목록
    @Default([]) List<Schedule> schedules,

    /// 폴더 목록
    @Default([]) List<FolderItem> folders,

    /// 필터 목록
    @Default([]) List<String> filters,

    /// 선택된 필터 인덱스
    @Default(0) int selectedFilterIndex,

    /// 로딩 상태
    @Default(true) bool isLoading,

    /// 에러 메시지
    String? errorMessage,
  }) = _HomeState;
}

/// 시간 문자열 포맷 변환 ("21:00:00" → "오후 9:00")
String _formatTime(String? timeStr) {
  if (timeStr == null || timeStr.isEmpty) return '';
  final parts = timeStr.split(':');
  if (parts.length < 2) return timeStr;

  var hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts[1];
  final period = hour < 12 ? '오전' : '오후';

  if (hour > 12) hour -= 12;
  if (hour == 0) hour = 12;

  return '$period $hour:$minute';
}

/// 일정 색상 매핑
Color _mapScheduleColor(String colorStr, int index) {
  // 서버 appColor 토큰(또는 hex)을 우선 사용
  // 예: blue300, yellow200, #FEEC88, blue_300
  final resolvedColor = EventColorTokens.fromToken(colorStr);
  return resolvedColor;
}

bool _isAllDaySchedule(ScheduleDto dto) {
  return (dto.startTime == null || dto.startTime!.isEmpty) &&
      (dto.endTime == null || dto.endTime!.isEmpty);
}

String _buildScheduleTimeLeftText({
  required String? endTime,
  required String? startTime,
}) {
  final targetTime = (endTime != null && endTime.isNotEmpty)
      ? endTime
      : startTime;
  if (targetTime == null || targetTime.isEmpty) return '';

  final parts = targetTime.split(':');
  if (parts.length < 2) return '';

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return '';

  final now = DateTime.now();
  var deadlineDateTime = DateTime(now.year, now.month, now.day, hour, minute);

  // 시작/종료 시간이 모두 있고 종료 시간이 시작 시간보다 이르면
  // 자정을 넘기는 일정으로 보고 마감 시점을 다음 날로 보정한다.
  if (startTime != null && startTime.isNotEmpty && endTime != null && endTime.isNotEmpty) {
    final startParts = startTime.split(':');
    if (startParts.length >= 2) {
      final startHour = int.tryParse(startParts[0]);
      final startMinute = int.tryParse(startParts[1]);
      if (startHour != null && startMinute != null) {
        final startDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          startHour,
          startMinute,
        );
        if (deadlineDateTime.isBefore(startDateTime)) {
          deadlineDateTime = deadlineDateTime.add(const Duration(days: 1));
        }
      }
    }
  }

  final diff = deadlineDateTime.difference(now);
  if (diff.inMinutes <= 0) return '마감됨';

  if (diff.inHours >= 1) {
    return '${diff.inHours}시간 전';
  }
  return '${diff.inMinutes}분 전';
}

/// DTO → Domain 변환: ScheduleDto → Schedule
Schedule _mapSchedule(ScheduleDto dto, int index) {
  final startFormatted = _formatTime(dto.startTime);
  final endFormatted = _formatTime(dto.endTime);
  final isAllDay = _isAllDaySchedule(dto);
  final timeRange = isAllDay ? '하루종일' : '$startFormatted - $endFormatted';

  return Schedule(
    title: dto.title,
    timeRangeText: timeRange,
    scheduleTime: isAllDay
        ? '오늘 마감'
        : _buildScheduleTimeLeftText(
            endTime: dto.endTime,
            startTime: dto.startTime,
          ),
    accentColor: _mapScheduleColor(dto.appColor, index),
  );
}

/// 색상 문자열 → colorIndex 변환
int _resolveColorIndex(String colorStr, int fallback) {
  if (colorStr.isEmpty) return fallback;
  final tokenIdx = AppColors.folderColorTokens.indexOf(colorStr);
  if (tokenIdx != -1) return tokenIdx;
  final color = AppColors.fromColorString(colorStr);
  final colorIdx = AppColors.folderColors.indexOf(color);
  return colorIdx != -1 ? colorIdx : fallback;
}

/// DTO → Domain 변환: FolderDto → FolderItem
FolderItem _mapFolder(FolderDto dto, int index, {String countText = '0개'}) {
  final ci = _resolveColorIndex(
    dto.color,
    index % AppColors.folderColors.length,
  );
  return FolderItem(
    foldersId: dto.foldersId,
    title: dto.name,
    memo: dto.memo,
    countText: countText,
    colorIndex: ci,
    isDefault: dto.isDefault,
    accentColor: AppColors.folderColors[ci],
  );
}

/// 홈 화면 컨트롤러 (Notifier)
class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    // 사용자 세션(로그인/로그아웃/복구) 변경 시 홈 상태 캐시를 재생성
    ref.watch(authSessionRefreshTickProvider);
    // 초기 데이터 로드 시작
    _loadHomeData();
    return const HomeState(isLoading: true);
  }

  /// 홈 화면 데이터 로드 (API)
  Future<void> _loadHomeData() async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      final authService = ref.read(authServiceProvider);
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final dto = await repository.fetchHomeData(todayDate: today);
      final tokenNickname = await authService.getNicknameFromToken();
      final resolvedUserName =
          (tokenNickname != null && tokenNickname.trim().isNotEmpty)
          ? tokenNickname.trim()
          : '사용자';

      // DTO → Domain 변환
      final schedules = dto.schedules
          .asMap()
          .entries
          .map((e) => _mapSchedule(e.value, e.key))
          .toList();

      final folders = dto.folders.asMap().entries.map((e) {
        return _mapFolder(e.value, e.key, countText: '${e.value.itemsCount}개');
      }).toList();

      state = state.copyWith(
        userName: resolvedUserName,
        todayScheduleCount: schedules.length,
        schedules: schedules,
        folders: folders,
        filters: const ['전체', '즐겨찾기'],
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '데이터를 불러오지 못했습니다: $e',
      );
    }
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _loadHomeData();
  }

  /// 보관함 삭제 (API 호출 → 목록 새로고침)
  Future<bool> deleteFolder({required int foldersId}) async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.deleteFolder(foldersId: foldersId);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: '보관함 삭제에 실패했습니다: $e');
      return false;
    }
  }

  /// 보관함 수정 (API 호출 → 목록 새로고침)
  Future<bool> updateFolder({
    required int foldersId,
    required String name,
    required String memo,
    required int colorIndex,
  }) async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      final colorToken = AppColors.folderColorTokens[colorIndex];

      await repository.updateFolder(
        foldersId: foldersId,
        name: name,
        memo: memo,
        color: colorToken,
      );

      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: '보관함 수정에 실패했습니다: $e');
      return false;
    }
  }

  /// 보관함 생성 (API 호출 → 목록 새로고침)
  Future<bool> createFolder({
    required String name,
    required String memo,
    required int colorIndex,
  }) async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      final colorToken = AppColors.folderColorTokens[colorIndex];

      await repository.createFolder(name: name, memo: memo, color: colorToken);

      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: '보관함 생성에 실패했습니다: $e');
      return false;
    }
  }

  /// 필터 선택
  void selectFilter(int index) {
    state = state.copyWith(selectedFilterIndex: index);
  }
}

/// 홈 화면 Provider
final homeProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

/// 일정 목록 Provider (최적화용)
final homeSchedulesProvider = Provider<List<Schedule>>((ref) {
  return ref.watch(homeProvider.select((s) => s.schedules));
});

/// 폴더 목록 Provider (최적화용)
final homeFoldersProvider = Provider<List<FolderItem>>((ref) {
  return ref.watch(homeProvider.select((s) => s.folders));
});

/// 선택된 필터 인덱스 Provider
final selectedFilterIndexProvider = Provider<int>((ref) {
  return ref.watch(homeProvider.select((s) => s.selectedFilterIndex));
});

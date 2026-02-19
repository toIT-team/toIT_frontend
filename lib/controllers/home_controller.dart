import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/constants/app_colors.dart';
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

/// 폴더 색상 매핑
Color _mapFolderColor(String colorStr, int index) {
  // TODO: 서버 색상 값 매핑 규칙 정의 후 수정
  const colors = AppColors.folderColors;
  return colors[index % colors.length];
}

/// 일정 색상 매핑
Color _mapScheduleColor(String colorStr, int index) {
  const colors = [
    AppColors.yellow200,
    AppColors.secondary,
    AppColors.green200,
    AppColors.pink100,
  ];
  return colors[index % colors.length];
}

/// DTO → Domain 변환: ScheduleDto → Schedule
Schedule _mapSchedule(ScheduleDto dto, int index) {
  final startFormatted = _formatTime(dto.startTime);
  final endFormatted = _formatTime(dto.endTime);
  final timeRange = startFormatted.isNotEmpty && endFormatted.isNotEmpty
      ? '$startFormatted - $endFormatted'
      : '하루종일';

  return Schedule(
    title: dto.title,
    timeRangeText: timeRange,
    scheduleTime: '', // TODO: 서버에서 남은시간 계산 또는 클라에서 계산
    accentColor: _mapScheduleColor(dto.appColor, index),
  );
}

/// DTO → Domain 변환: FolderDto → FolderItem
FolderItem _mapFolder(FolderDto dto, int index) {
  return FolderItem(
    title: dto.name,
    countText: '', // TODO: 폴더 내 항목 수 API 추가 시 반영
    accentColor: _mapFolderColor(dto.color, index),
  );
}

/// 홈 화면 컨트롤러 (Notifier)
class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    // 초기 데이터 로드 시작
    _loadHomeData();
    return const HomeState(isLoading: true);
  }

  /// 홈 화면 데이터 로드 (API)
  Future<void> _loadHomeData() async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final dto = await repository.fetchHomeData(todayDate: today);

      // DTO → Domain 변환
      final schedules = dto.schedules
          .asMap()
          .entries
          .map((e) => _mapSchedule(e.value, e.key))
          .toList();

      final folders = dto.folders
          .asMap()
          .entries
          .map((e) => _mapFolder(e.value, e.key))
          .toList();

      state = state.copyWith(
        userName: '사용자',
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

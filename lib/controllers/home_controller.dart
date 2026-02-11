import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/constants/app_colors.dart';
import '../models/home/folder_item.dart';
import '../models/home/schedule.dart';

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
    @Default(false) bool isLoading,
  }) = _HomeState;
}

/// 홈 화면 컨트롤러 (Notifier)
class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    // 초기 데이터를 동기적으로 설정 (캘린더와 동일한 패턴)
    return HomeState(
      userName: '리나',
      todayScheduleCount: 2,
      schedules: [
        Schedule(
          title: '시각디자인 설명회',
          timeRangeText: '오후10:00 - 오후11:00',
          scheduleTime: '30분 전',
          accentColor: AppColors.folderYellow,
        ),
        Schedule(
          title: '임상실험학',
          timeRangeText: '하루종일',
          scheduleTime: '오늘 마감',
          accentColor: AppColors.secondary,
        ),
      ],
      folders: [
        FolderItem(
          title: '공부',
          countText: '12개',
          accentColor: AppColors.folderBlue,
        ),
        FolderItem(
          title: '디자인',
          countText: '8개',
          accentColor: AppColors.folderYellow,
        ),
        FolderItem(
          title: '콘서트',
          countText: '1개',
          accentColor: AppColors.folderGreen,
        ),
        FolderItem(
          title: '공부',
          countText: '1개',
          accentColor: AppColors.folderGray,
        ),
      ],
      filters: const ['전체', '즐겨찾기', '공부', '디자인', '개발'],
    );
  }

  /// 데이터 새로고침 (API 연동 시 사용)
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);

    // TODO: 실제 API 연동 시 datasource/repository 사용
    await Future.delayed(const Duration(milliseconds: 300));

    // 데이터 다시 로드
    state = state.copyWith(
      userName: '리나',
      todayScheduleCount: 2,
      schedules: [
        Schedule(
          title: '시각디자인 설명회',
          timeRangeText: '오후10:00 - 오후11:00',
          scheduleTime: '30분 전',
          accentColor: AppColors.folderYellow,
        ),
        Schedule(
          title: '임상실험학',
          timeRangeText: '하루종일',
          scheduleTime: '오늘 마감',
          accentColor: AppColors.secondary,
        ),
      ],
      folders: [
        FolderItem(
          title: '공부',
          countText: '12개',
          accentColor: AppColors.folderBlue,
        ),
        FolderItem(
          title: '디자인',
          countText: '8개',
          accentColor: AppColors.folderYellow,
        ),
        FolderItem(
          title: '콘서트',
          countText: '1개',
          accentColor: AppColors.folderGreen,
        ),
        FolderItem(
          title: '공부',
          countText: '1개',
          accentColor: AppColors.folderGray,
        ),
      ],
      filters: const ['전체', '즐겨찾기', '공부', '디자인', '개발'],
      isLoading: false,
    );
  }

  /// 필터 선택
  void selectFilter(int index) {
    state = state.copyWith(selectedFilterIndex: index);
    // TODO: 필터에 따른 폴더 목록 필터링 로직 추가
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

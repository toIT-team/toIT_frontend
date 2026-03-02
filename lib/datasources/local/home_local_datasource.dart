import '../../core/constants/app_colors.dart';
import '../../models/home/folder_item.dart';
import '../../models/home/home_data.dart';
import '../../models/home/schedule.dart';

/// 홈 화면 로컬 데이터 소스 (목 데이터)
class HomeLocalDatasource {
  const HomeLocalDatasource();

  /// 홈 화면 데이터 조회
  HomeData fetchHomeData() {
    return HomeData(
      userName: '리나',
      todayScheduleCount: 2,
      schedules: [
        Schedule(
          title: '시각디자인 설명회',
          timeRangeText: '오후10:00 - 오후11:00',
          scheduleTime: '30분 전',
          accentColor: AppColors.yellow200,
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
          accentColor: AppColors.blue300,
        ),
        FolderItem(
          title: '디자인',
          countText: '8개',
          accentColor: AppColors.yellow200,
        ),
        FolderItem(
          title: '콘서트',
          countText: '1개',
          accentColor: AppColors.green200,
        ),
        FolderItem(
          title: '공부',
          countText: '1개',
          accentColor: AppColors.gray100,
        ),
      ],
      filters: const ['전체', '즐겨찾기', '공부', '디자인', '개발'],
    );
  }
}

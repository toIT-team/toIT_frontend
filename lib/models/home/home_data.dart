import 'folder_item.dart';
import 'schedule.dart';

/// 홈 화면 전체 데이터 모델
class HomeData {
  final String userName;
  final int todayScheduleCount;
  final List<Schedule> schedules;
  final List<FolderItem> folders;
  final List<String> filters;

  const HomeData({
    required this.userName,
    required this.todayScheduleCount,
    required this.schedules,
    required this.folders,
    required this.filters,
  });
}

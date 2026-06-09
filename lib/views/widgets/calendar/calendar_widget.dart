import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../controllers/calendar_controller.dart';
import '../../../services/schedule_api_client.dart' show scheduleApiClientProvider;
import 'calendar_grid.dart';
import 'calendar_header.dart';
import 'calendar_year_month_picker.dart';
import 'day_events_bottom_sheet.dart';

/// 메인 캘린더 위젯
class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  late PageController _pageController;

  /// 년월 피커를 월 라벨 바로 아래에 맞추기 위한 앵커
  final GlobalKey _monthAnchorKey = GlobalKey();

  /// [PageController.animateToPage]로 맞추는 동안 [PageView.onPageChanged]를
  /// 무시한다. 중첩 애니메이션마다 +1 / 완료 시 -1.
  int _programmaticPageAnimationDepth = 0;

  /// 초기 페이지 인덱스 (무한 스크롤을 위한 중간값)
  static const int _initialPage = 1000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    // 초기 로드: API에서 현재 월 일정 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final month = ref.read(calendarProvider).focusedMonth;
      ref.read(calendarProvider.notifier).loadEvents(month);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 페이지 인덱스에서 월 계산
  DateTime _getMonthFromPage(int pageIndex) {
    final monthOffset = pageIndex - _initialPage;
    final now = DateTime.now();
    return DateTime(now.year, now.month + monthOffset, 1);
  }

  /// 월에서 페이지 인덱스 계산
  int _getPageFromMonth(DateTime month) {
    final now = DateTime.now();
    final baseMonth = DateTime(now.year, now.month, 1);
    final monthDiff =
        (month.year - baseMonth.year) * 12 + (month.month - baseMonth.month);
    return _initialPage + monthDiff;
  }

  /// 일정 바텀시트 표시 (GET /page/schedules/selected API 호출)
  Future<void> _showDayEventsSheet(BuildContext context, DateTime date) async {
    ref.read(calendarProvider.notifier).selectDate(date);

    final apiClient = ref.read(scheduleApiClientProvider);
    final dayEvents = await apiClient.getSelectedDaySchedules(
      selectedDay: date,
    );

    if (!context.mounted) return;

    dayEvents.sort((a, b) {
      // 하루 종일 일정 먼저, 그 다음 시간순
      if (!a.timeSetting && b.timeSetting) return -1;
      if (a.timeSetting && !b.timeSetting) return 1;
      if (a.startTime != null && b.startTime != null) {
        return a.startTime!.compareTo(b.startTime!);
      }
      return 0;
    });

    showDayEventsBottomSheet(context, date, dayEvents);
  }

  @override
  Widget build(BuildContext context) {
    // 헤더용 focusedMonth, 로딩 상태 watch
    final focusedMonth = ref.watch(
      calendarProvider.select((s) => s.focusedMonth),
    );
    final isLoading = ref.watch(
      calendarProvider.select((s) => s.isLoading),
    );
    // 일정 추가/수정 시 즉시 반영을 위해 events watch
    ref.watch(eventsProvider);
    final calendarController = ref.read(calendarProvider.notifier);

    // 외부에서 월이 변경되면 페이지도 이동 (Picker에서 선택 시)
    ref.listen(
      calendarProvider.select((s) => s.focusedMonth),
      (previous, next) {
        if (previous != next) {
          final targetPage = _getPageFromMonth(next);
          if (_pageController.hasClients &&
              _pageController.page?.round() != targetPage) {
            _programmaticPageAnimationDepth++;
            _pageController
                .animateToPage(
                  targetPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                )
                .whenComplete(() {
              if (!mounted) return;
              _programmaticPageAnimationDepth--;
              if (_programmaticPageAnimationDepth < 0) {
                _programmaticPageAnimationDepth = 0;
              }
            });
          }
        }
      },
    );

    return Stack(
      children: [
        Column(
          children: [
            CalendarHeader(
                monthSelectorKey: _monthAnchorKey,
                focusedMonth: focusedMonth,
                onMonthTap: () {
                  showCalendarYearMonthPicker(
                    context,
                    ref,
                    anchorKey: _monthAnchorKey,
                    currentMonth: focusedMonth,
                    fallbackPanelTop:
                        MediaQuery.paddingOf(context).top + 56 + 48,
                  );
                },
              ),
            Expanded(
              child: PageView.builder(
            controller: _pageController,
            // 슬라이드 완료 후 헤더만 업데이트
            onPageChanged: (page) {
              if (_programmaticPageAnimationDepth > 0) return;
              final newMonth = _getMonthFromPage(page);
              if (newMonth.year != focusedMonth.year ||
                  newMonth.month != focusedMonth.month) {
                // 비동기로 상태 업데이트 (UI 블로킹 방지)
                Future.microtask(() {
                  calendarController.goToMonth(newMonth);
                });
              }
            },
            itemBuilder: (context, index) {
              final month = _getMonthFromPage(index);
              return CalendarGrid(
                focusedMonth: month,
                onDayTap: (date) => _showDayEventsSheet(context, date),
              );
            },
          ),
        ),
          ],
        ),
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.loadingIndicator,
              ),
            ),
          ),
      ],
    );
  }
}

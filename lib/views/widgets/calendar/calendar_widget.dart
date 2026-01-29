import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/calendar_controller.dart';
import 'calendar_grid.dart';
import 'calendar_header.dart';

/// 메인 캘린더 위젯
class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  late PageController _pageController;

  /// 초기 페이지 인덱스 (무한 스크롤을 위한 중간값)
  static const int _initialPage = 1000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
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

  /// 년/월 선택 Picker 표시
  void _showYearMonthPicker(BuildContext context, DateTime currentMonth) {
    var selectedYear = currentMonth.year;
    var selectedMonth = currentMonth.month;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 280,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // 년 선택
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 44,
                              perspective: 0.005,
                              diameterRatio: 1.5,
                              physics: const FixedExtentScrollPhysics(),
                              controller: FixedExtentScrollController(
                                initialItem: selectedYear - 2020,
                              ),
                              onSelectedItemChanged: (index) {
                                setDialogState(() {
                                  selectedYear = 2020 + index;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 20,
                                builder: (context, index) {
                                  final year = 2020 + index;
                                  final isSelected = year == selectedYear;
                                  return Center(
                                    child: Text(
                                      '$year년',
                                      style: TextStyle(
                                        fontSize: isSelected ? 20 : 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // 월 선택
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 44,
                              perspective: 0.005,
                              diameterRatio: 1.5,
                              physics: const FixedExtentScrollPhysics(),
                              controller: FixedExtentScrollController(
                                initialItem: selectedMonth - 1,
                              ),
                              onSelectedItemChanged: (index) {
                                setDialogState(() {
                                  selectedMonth = index + 1;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 12,
                                builder: (context, index) {
                                  final month = index + 1;
                                  final isSelected = month == selectedMonth;
                                  return Center(
                                    child: Text(
                                      '$month월',
                                      style: TextStyle(
                                        fontSize: isSelected ? 20 : 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // 다이얼로그가 닫힐 때 월 이동 적용
      final controller = ref.read(calendarProvider.notifier);
      controller.goToMonth(DateTime(selectedYear, selectedMonth));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 헤더용 focusedMonth만 watch (선택적 구독)
    final focusedMonth = ref.watch(
      calendarProvider.select((s) => s.focusedMonth),
    );
    final calendarController = ref.read(calendarProvider.notifier);

    // 외부에서 월이 변경되면 페이지도 이동 (Picker에서 선택 시)
    ref.listen(
      calendarProvider.select((s) => s.focusedMonth),
      (previous, next) {
        if (previous != next) {
          final targetPage = _getPageFromMonth(next);
          if (_pageController.hasClients &&
              _pageController.page?.round() != targetPage) {
            _pageController.animateToPage(
              targetPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
    );

    return Column(
      children: [
        // 헤더
        CalendarHeader(
          focusedMonth: focusedMonth,
          onMonthTap: () {
            _showYearMonthPicker(context, focusedMonth);
          },
        ),
        // 캘린더 본체 (스와이프 가능)
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            // 슬라이드 완료 후 헤더만 업데이트
            onPageChanged: (page) {
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
                onDayTap: (date) {
                  calendarController.selectDate(date);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

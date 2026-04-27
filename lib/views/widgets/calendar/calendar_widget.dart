import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../controllers/calendar_controller.dart';
import '../../../services/schedule_api_client.dart' show scheduleApiClientProvider;
import 'calendar_grid.dart';
import 'calendar_header.dart';
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

  /// 년/월 선택 피커 (딤 없음, 월 라벨 바로 아래 · 그림자만으로 떠 보이게)
  void _showYearMonthPicker(BuildContext context, DateTime currentMonth) {
    var selectedYear = currentMonth.year;
    var selectedMonth = currentMonth.month;

    final mediaQuery = MediaQuery.of(context);
    final overlayState = Overlay.of(context);
    final overlayBox =
        overlayState.context.findRenderObject() as RenderBox?;

    const horizontalPad = 20.0;
    final screenW = mediaQuery.size.width;
    final panelWidth = (screenW - horizontalPad * 2).clamp(260.0, 320.0);

    double panelLeft = (screenW - panelWidth) / 2;
    double panelTop = mediaQuery.padding.top + 56 + 48;

    final anchorCtx = _monthAnchorKey.currentContext;
    if (anchorCtx != null &&
        overlayBox != null &&
        overlayBox.attached) {
      final anchorBox = anchorCtx.findRenderObject() as RenderBox?;
      if (anchorBox != null && anchorBox.attached) {
        final origin = anchorBox.localToGlobal(
          Offset.zero,
          ancestor: overlayBox,
        );
        final centerX = origin.dx + anchorBox.size.width / 2;
        panelLeft = (centerX - panelWidth / 2).clamp(
          horizontalPad,
          screenW - horizontalPad - panelWidth,
        );
        panelTop = origin.dy + anchorBox.size.height + 8;
      }
    }

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel:
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              Positioned(
                left: panelLeft,
                top: panelTop,
                width: panelWidth,
                height: 292,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(0, 10),
                          blurRadius: 28,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _YearMonthWheelPicker(
                        initialMonth: currentMonth,
                        onSelectionChanged: (y, m) {
                          selectedYear = y;
                          selectedMonth = m;
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (!context.mounted) return;
      final unchanged = selectedYear == currentMonth.year &&
          selectedMonth == currentMonth.month;
      if (unchanged) return;
      ref.read(calendarProvider.notifier).goToMonth(
            DateTime(selectedYear, selectedMonth, 1),
          );
    });
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
            // 헤더
            CalendarHeader(
              monthSelectorKey: _monthAnchorKey,
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

/// 년·월 휠 (스크롤 컨트롤러 생명주기 분리)
class _YearMonthWheelPicker extends StatefulWidget {
  const _YearMonthWheelPicker({
    required this.initialMonth,
    required this.onSelectionChanged,
  });

  final DateTime initialMonth;
  final void Function(int year, int month) onSelectionChanged;

  @override
  State<_YearMonthWheelPicker> createState() =>
      _YearMonthWheelPickerState();
}

class _YearMonthWheelPickerState extends State<_YearMonthWheelPicker> {
  static const int _yearBase = 2020;
  static const int _yearCount = 20;

  late int _selectedYear;
  late int _selectedMonth;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialMonth.year;
    _selectedMonth = widget.initialMonth.month;
    _yearController = FixedExtentScrollController(
      initialItem: (_selectedYear - _yearBase).clamp(0, _yearCount - 1),
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onSelectionChanged(_selectedYear, _selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: _yearController,
              itemExtent: 44,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedYear = _yearBase + index;
                });
                _emit();
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _yearCount,
                builder: (context, index) {
                  final year = _yearBase + index;
                  final isSelected = year == _selectedYear;
                  return Center(
                    child: Text(
                      '$year년',
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.gray900
                            : AppColors.gray600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: _monthController,
              itemExtent: 44,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedMonth = index + 1;
                });
                _emit();
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 12,
                builder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == _selectedMonth;
                  return Center(
                    child: Text(
                      '$month월',
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.gray900
                            : AppColors.gray600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

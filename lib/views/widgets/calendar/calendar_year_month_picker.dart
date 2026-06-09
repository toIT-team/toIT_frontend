import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/calendar_controller.dart';
import '../../../core/constants/app_colors.dart';

/// 년·월 오버레이 피커 표시
Future<void> showCalendarYearMonthPicker(
  BuildContext context,
  WidgetRef ref, {
  required DateTime currentMonth,
  GlobalKey? anchorKey,
  double fallbackPanelTop = 0,
}) async {
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
  double panelTop = fallbackPanelTop > 0
      ? fallbackPanelTop
      : mediaQuery.padding.top + 56;

  final anchorCtx = anchorKey?.currentContext;
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

  await showGeneralDialog<void>(
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
                    child: CalendarYearMonthWheelPicker(
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
  );

  if (!context.mounted) return;
  final unchanged = selectedYear == currentMonth.year &&
      selectedMonth == currentMonth.month;
  if (unchanged) return;
  ref.read(calendarProvider.notifier).goToMonth(
        DateTime(selectedYear, selectedMonth, 1),
      );
}

/// 년·월 휠 피커
class CalendarYearMonthWheelPicker extends StatefulWidget {
  const CalendarYearMonthWheelPicker({
    super.key,
    required this.initialMonth,
    required this.onSelectionChanged,
  });

  final DateTime initialMonth;
  final void Function(int year, int month) onSelectionChanged;

  @override
  State<CalendarYearMonthWheelPicker> createState() =>
      _CalendarYearMonthWheelPickerState();
}

class _CalendarYearMonthWheelPickerState
    extends State<CalendarYearMonthWheelPicker> {
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

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../common/custom_toggle.dart';
import 'event_time_row.dart';

/// 시간 설정 섹션 (시작/종료 시간)
///
/// [isEditable] false: 일정 상세 모드 (읽기 전용)
/// [isEditable] true: 수정 모드 (토글 + 날짜/시간 편집)
class EventTimeSection extends StatefulWidget {
  const EventTimeSection({
    super.key,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    this.isEditable = false,
    this.timeSetting = false,
    this.onTimeSettingChanged,
    this.onStartDateChanged,
    this.onStartTimeChanged,
    this.onEndDateChanged,
    this.onEndTimeChanged,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String? startTime;
  final String? endTime;
  final bool isEditable;
  final bool timeSetting;
  final ValueChanged<bool>? onTimeSettingChanged;
  final ValueChanged<DateTime>? onStartDateChanged;
  final ValueChanged<String>? onStartTimeChanged;
  final ValueChanged<DateTime>? onEndDateChanged;
  final ValueChanged<String>? onEndTimeChanged;

  /// 시간이 표시되어야 하는지 여부
  bool get showTime => isEditable ? timeSetting : startTime != null;

  @override
  State<EventTimeSection> createState() => _EventTimeSectionState();
}

class _EventTimeSectionState extends State<EventTimeSection> {
  _InlinePickerTarget? _activeTarget;
  late DateTime _displayedMonth;
  bool _showMonthYearPicker = false;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.startDate.year, widget.startDate.month, 1);
  }

  @override
  void didUpdateWidget(covariant EventTimeSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.showTime && _isTimeTarget(_activeTarget)) {
      _activeTarget = null;
    }

    if (_activeTarget == null) {
      _displayedMonth = DateTime(widget.startDate.year, widget.startDate.month, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showStartPicker =
        widget.isEditable &&
        (_activeTarget == _InlinePickerTarget.startDate ||
            _activeTarget == _InlinePickerTarget.startTime);
    final showEndPicker =
        widget.isEditable &&
        (_activeTarget == _InlinePickerTarget.endDate ||
            _activeTarget == _InlinePickerTarget.endTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '시간 설정',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.isEditable)
              CustomToggle(
                value: widget.timeSetting,
                onChanged: widget.onTimeSettingChanged,
              ),
          ],
        ),
        const SizedBox(height: 16),
        EventTimeRow(
          label: '시작',
          date: widget.startDate,
          time: widget.showTime ? widget.startTime : null,
          showTimeChip: widget.showTime,
          isEditable: widget.isEditable,
          onDateTap: () => _onDateChipTap(_InlinePickerTarget.startDate),
          onTimeTap: widget.showTime
              ? () => _onTimeChipTap(_InlinePickerTarget.startTime)
              : null,
          isDateActive: _activeTarget == _InlinePickerTarget.startDate,
          isTimeActive: _activeTarget == _InlinePickerTarget.startTime,
        ),
        if (showStartPicker) ...[
          const SizedBox(height: 16),
          _buildWiderInlinePicker(),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 12),
        EventTimeRow(
          label: '종료',
          date: widget.endDate,
          time: widget.showTime ? widget.endTime : null,
          showTimeChip: widget.showTime,
          isEditable: widget.isEditable,
          onDateTap: () => _onDateChipTap(_InlinePickerTarget.endDate),
          onTimeTap: widget.showTime
              ? () => _onTimeChipTap(_InlinePickerTarget.endTime)
              : null,
          isDateActive: _activeTarget == _InlinePickerTarget.endDate,
          isTimeActive: _activeTarget == _InlinePickerTarget.endTime,
        ),
        if (showEndPicker) ...[
          const SizedBox(height: 16),
          _buildWiderInlinePicker(),
        ],
      ],
    );
  }

  Widget _buildWiderInlinePicker() {
    const extraWidth = 36.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Transform.translate(
          offset: const Offset(-(extraWidth / 2), 0),
          child: SizedBox(
            width: constraints.maxWidth + extraWidth,
            child: _buildInlinePicker(),
          ),
        );
      },
    );
  }

  void _onDateChipTap(_InlinePickerTarget target) {
    setState(() {
      if (_activeTarget == target) {
        _activeTarget = null;
        _showMonthYearPicker = false;
        return;
      }
      _activeTarget = target;
      final selectedDate = _selectedDateForTarget(target);
      _displayedMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      _showMonthYearPicker = false;
    });
  }

  void _onTimeChipTap(_InlinePickerTarget target) {
    setState(() {
      if (_activeTarget == target) {
        _activeTarget = null;
        return;
      }
      _activeTarget = target;
      _showMonthYearPicker = false;
    });
  }

  Widget _buildInlinePicker() {
    if (_isDateTarget(_activeTarget)) {
      return _buildCalendarPicker();
    }

    final initialTime = _selectedTimeForTarget(_activeTarget!);
    return _InlineTimeWheelPicker(
      initialTime: initialTime,
      onChanged: (value) {
        if (_activeTarget == _InlinePickerTarget.startTime) {
          widget.onStartTimeChanged?.call(value);
        } else if (_activeTarget == _InlinePickerTarget.endTime) {
          widget.onEndTimeChanged?.call(value);
        }
      },
    );
  }

  Widget _buildCalendarPicker() {
    final selectedDate = _selectedDateForTarget(_activeTarget!);
    final days = _buildMonthCells(_displayedMonth);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                      1,
                    );
                    _showMonthYearPicker = false;
                  });
                },
                icon: const Icon(Icons.chevron_left, color: Colors.black54),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _showMonthYearPicker = !_showMonthYearPicker;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_displayedMonth.year}.${_displayedMonth.month.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.gray900,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showMonthYearPicker
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month + 1,
                      1,
                    );
                    _showMonthYearPicker = false;
                  });
                },
                icon: const Icon(Icons.chevron_right, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Column(
                children: [
                  _buildWeekdayHeader(),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final isSelected = _isSameDay(day.date, selectedDate);
                      final isToday = _isSameDay(day.date, DateTime.now());

                      return GestureDetector(
                        onTap: () => _onDateSelected(day.date),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.blue500 : null,
                          ),
                          child: Text(
                            '${day.date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected
                                  ? AppColors.surface
                                  : (day.isCurrentMonth
                                      ? AppColors.gray900
                                      : AppColors.gray400),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : (isToday ? FontWeight.w700 : FontWeight.w500),
                              decoration: isToday && !isSelected
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationColor: AppColors.blue500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (_showMonthYearPicker)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.97),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _MonthYearWheelPicker(
                      initialYear: _displayedMonth.year,
                      initialMonth: _displayedMonth.month,
                      minYear: 2020,
                      maxYear: 2035,
                      onChanged: (year, month) {
                        setState(() {
                          _displayedMonth = DateTime(year, month, 1);
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  DateTime _selectedDateForTarget(_InlinePickerTarget target) {
    if (target == _InlinePickerTarget.startDate ||
        target == _InlinePickerTarget.startTime) {
      return widget.startDate;
    }
    return widget.endDate;
  }

  String _selectedTimeForTarget(_InlinePickerTarget target) {
    if (target == _InlinePickerTarget.startTime) {
      return widget.startTime ?? '09:00';
    }
    return widget.endTime ?? '10:00';
  }

  List<_CalendarCell> _buildMonthCells(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final firstWeekdayOffset = firstDay.weekday - 1;
    final daysInCurrentMonth = DateTime(month.year, month.month + 1, 0).day;

    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final prevMonthDays = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

    final cells = <_CalendarCell>[];

    for (var i = 0; i < 42; i++) {
      final dayNumber = i - firstWeekdayOffset + 1;
      if (dayNumber < 1) {
        final day = prevMonthDays + dayNumber;
        cells.add(
          _CalendarCell(
            date: DateTime(prevMonth.year, prevMonth.month, day),
            isCurrentMonth: false,
          ),
        );
        continue;
      }

      if (dayNumber > daysInCurrentMonth) {
        final nextMonthDay = dayNumber - daysInCurrentMonth;
        cells.add(
          _CalendarCell(
            date: DateTime(month.year, month.month + 1, nextMonthDay),
            isCurrentMonth: false,
          ),
        );
        continue;
      }

      cells.add(
        _CalendarCell(
          date: DateTime(month.year, month.month, dayNumber),
          isCurrentMonth: true,
        ),
      );
    }

    return cells;
  }

  void _onDateSelected(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);

    if (_activeTarget == _InlinePickerTarget.startDate) {
      widget.onStartDateChanged?.call(normalized);
    } else if (_activeTarget == _InlinePickerTarget.endDate) {
      widget.onEndDateChanged?.call(normalized);
    }

    setState(() {
      _displayedMonth = DateTime(normalized.year, normalized.month, 1);
    });
  }

  bool _isDateTarget(_InlinePickerTarget? target) {
    return target == _InlinePickerTarget.startDate ||
        target == _InlinePickerTarget.endDate;
  }

  bool _isTimeTarget(_InlinePickerTarget? target) {
    return target == _InlinePickerTarget.startTime ||
        target == _InlinePickerTarget.endTime;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _InlineTimeWheelPicker extends StatefulWidget {
  const _InlineTimeWheelPicker({
    required this.initialTime,
    required this.onChanged,
  });

  final String initialTime;
  final ValueChanged<String> onChanged;

  @override
  State<_InlineTimeWheelPicker> createState() => _InlineTimeWheelPickerState();
}

class _InlineTimeWheelPickerState extends State<_InlineTimeWheelPicker> {
  static const _itemExtent = 46.0;
  static const _minutes = [
    0,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    55,
  ];
  static const _periods = ['오전', '오후'];

  late int _periodIndex;
  late int _hourIndex;
  late int _minuteIndex;

  late final FixedExtentScrollController _periodController;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final parsed = _parseTime(widget.initialTime);
    _periodIndex = parsed.periodIndex;
    _hourIndex = parsed.hour12 - 1;
    _minuteIndex = _nearestMinuteIndex(parsed.minute);

    _periodController = FixedExtentScrollController(initialItem: _periodIndex);
    _hourController = FixedExtentScrollController(initialItem: _hourIndex);
    _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyTimeChanged();
    });
  }

  @override
  void didUpdateWidget(covariant _InlineTimeWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTime == widget.initialTime) return;

    final parsed = _parseTime(widget.initialTime);
    _periodIndex = parsed.periodIndex;
    _hourIndex = parsed.hour12 - 1;
    _minuteIndex = _nearestMinuteIndex(parsed.minute);

    _periodController.jumpToItem(_periodIndex);
    _hourController.jumpToItem(_hourIndex);
    _minuteController.jumpToItem(_minuteIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyTimeChanged();
    });
  }

  @override
  void dispose() {
    _periodController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildWheel(
              controller: _periodController,
              itemCount: _periods.length,
              labelBuilder: (index) => _periods[index],
              onSelectedItemChanged: (index) {
                setState(() {
                  _periodIndex = index;
                });
                _notifyTimeChanged();
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildWheel(
              controller: _hourController,
              itemCount: 12,
              labelBuilder: (index) => '${index + 1}',
              onSelectedItemChanged: (index) {
                setState(() {
                  _hourIndex = index;
                });
                _notifyTimeChanged();
              },
            ),
          ),
          const SizedBox(
            width: 20,
            child: Center(
              child: Text(
                ':',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildWheel(
              controller: _minuteController,
              itemCount: _minutes.length,
              labelBuilder: (index) => _minutes[index].toString().padLeft(2, '0'),
              onSelectedItemChanged: (index) {
                setState(() {
                  _minuteIndex = index;
                });
                _notifyTimeChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int index) labelBuilder,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _itemExtent,
      perspective: 0.004,
      diameterRatio: 1.3,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = controller.hasClients
              ? (controller.selectedItem == index)
              : false;

          return Center(
            child: Text(
              labelBuilder(index),
              style: TextStyle(
                fontSize: 20,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.gray900 : AppColors.gray400,
              ),
            ),
          );
        },
      ),
    );
  }

  void _notifyTimeChanged() {
    final hour12 = _hourIndex + 1;
    final minute = _minutes[_minuteIndex];

    final hour24 = switch (_periodIndex) {
      0 => hour12 == 12 ? 0 : hour12,
      _ => hour12 == 12 ? 12 : hour12 + 12,
    };

    final formatted =
        '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    widget.onChanged(formatted);
  }

  ({int periodIndex, int hour12, int minute}) _parseTime(String value) {
    final parts = value.split(':');
    final hour24 = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
    final minute = parts.length >= 2 ? int.tryParse(parts[1]) ?? 0 : 0;

    final periodIndex = hour24 >= 12 ? 1 : 0;
    final normalizedHour = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return (periodIndex: periodIndex, hour12: normalizedHour, minute: minute);
  }

  int _nearestMinuteIndex(int minute) {
    var nearestIndex = 0;
    var minDiff = 60;

    for (var i = 0; i < _minutes.length; i++) {
      final diff = (minute - _minutes[i]).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }
}

class _MonthYearWheelPicker extends StatefulWidget {
  const _MonthYearWheelPicker({
    required this.initialYear,
    required this.initialMonth,
    required this.minYear,
    required this.maxYear,
    required this.onChanged,
  });

  final int initialYear;
  final int initialMonth;
  final int minYear;
  final int maxYear;
  final void Function(int year, int month) onChanged;

  @override
  State<_MonthYearWheelPicker> createState() => _MonthYearWheelPickerState();
}

class _MonthYearWheelPickerState extends State<_MonthYearWheelPicker> {
  static const _itemExtent = 52.0;

  late int _selectedYear;
  late int _selectedMonth;

  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _monthController;

  int get _yearCount => widget.maxYear - widget.minYear + 1;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;

    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - widget.minYear,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildWheel(
              controller: _yearController,
              itemCount: _yearCount,
              labelBuilder: (index) => '${widget.minYear + index}년',
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedYear = widget.minYear + index;
                });
                widget.onChanged(_selectedYear, _selectedMonth);
              },
            ),
          ),
          Expanded(
            child: _buildWheel(
              controller: _monthController,
              itemCount: 12,
              labelBuilder: (index) => '${index + 1}월',
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedMonth = index + 1;
                });
                widget.onChanged(_selectedYear, _selectedMonth);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int index) labelBuilder,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _itemExtent,
      perspective: 0.004,
      diameterRatio: 1.6,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = controller.hasClients
              ? (controller.selectedItem == index)
              : false;
          return Center(
            child: Text(
              labelBuilder(index),
              style: TextStyle(
                fontSize: 20,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.gray900 : AppColors.gray400,
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _InlinePickerTarget { startDate, startTime, endDate, endTime }

class _CalendarCell {
  _CalendarCell({
    required this.date,
    required this.isCurrentMonth,
  });

  final DateTime date;
  final bool isCurrentMonth;
}

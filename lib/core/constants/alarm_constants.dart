/// 알림 직접 설정 단위
enum AlarmUnit {
  minutes('분'),
  hours('시간'),
  days('일');

  const AlarmUnit(this.label);
  final String label;
}

class AlarmOptionItem {
  const AlarmOptionItem({
    required this.minutes,
    required this.label,
    this.enabled = true,
  });

  final int minutes;
  final String label;
  final bool enabled;
}

/// 알림 유틸리티
class AlarmUtils {
  AlarmUtils._();

  static const int maxOffsetMinutes = 10080;

  /// 값과 단위를 분 단위로 변환
  static int toMinutes(int value, AlarmUnit unit) {
    switch (unit) {
      case AlarmUnit.minutes:
        return value;
      case AlarmUnit.hours:
        return value * 60;
      case AlarmUnit.days:
        return value * 1440;
    }
  }

  static int clampOffsetMinutes(int minutes) {
    return minutes.clamp(0, maxOffsetMinutes);
  }

  static int maxValueForUnit(AlarmUnit unit) {
    switch (unit) {
      case AlarmUnit.minutes:
        return 99;
      case AlarmUnit.hours:
        return 99;
      case AlarmUnit.days:
        return maxOffsetMinutes ~/ 1440;
    }
  }

  /// 분 단위를 (값, 단위)로 변환 (직접 설정 피커 초기값용)
  static (int, AlarmUnit) fromMinutes(int minutes) {
    final clampedMinutes = clampOffsetMinutes(minutes);
    if (clampedMinutes >= 60 && clampedMinutes % 60 == 0) {
      final hours = clampedMinutes ~/ 60;
      if (hours <= 99) return (hours, AlarmUnit.hours);
    }
    if (clampedMinutes >= 1440 && clampedMinutes % 1440 == 0) {
      final days = clampedMinutes ~/ 1440;
      if (days <= 99) return (days, AlarmUnit.days);
    }
    return (clampedMinutes.clamp(0, 99), AlarmUnit.minutes);
  }

  /// 사전 정의된 알림 옵션 (분, 라벨)
  static const predefinedOptions = <AlarmOptionItem>[
    AlarmOptionItem(minutes: 0, label: '일정 시작'),
    AlarmOptionItem(minutes: 5, label: '5분 전'),
    AlarmOptionItem(minutes: 10, label: '10분 전'),
    AlarmOptionItem(minutes: 60, label: '1시간 전'),
    AlarmOptionItem(minutes: 1440, label: '1일 전'),
  ];

  static const predefinedMinutes = [0, 5, 10, 60, 1440];

  static const _allDayPresetOptions = <AlarmOptionItem>[
    AlarmOptionItem(minutes: 0, label: '이벤트 당일(09:00)'),
    AlarmOptionItem(minutes: 1440, label: '1일 전(09:00)'),
    AlarmOptionItem(minutes: 2880, label: '2일 전(09:00)'),
    AlarmOptionItem(minutes: 10080, label: '1주 전'),
  ];

  static List<AlarmOptionItem> allDayPresetOptions({
    required DateTime startDate,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final eventBase = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      9,
    );

    return _allDayPresetOptions
        .map((option) {
          final alarmAt = eventBase.subtract(Duration(minutes: option.minutes));
          return AlarmOptionItem(
            minutes: option.minutes,
            label: option.label,
            enabled: !alarmAt.isBefore(current),
          );
        })
        .toList(growable: false);
  }
}

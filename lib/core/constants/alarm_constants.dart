/// 알림 직접 설정 단위
enum AlarmUnit {
  minutes('분'),
  hours('시간'),
  days('일');

  const AlarmUnit(this.label);
  final String label;
}

/// 알림 유틸리티
class AlarmUtils {
  AlarmUtils._();

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

  /// 분 단위를 (값, 단위)로 변환 (직접 설정 피커 초기값용)
  static (int, AlarmUnit) fromMinutes(int minutes) {
    if (minutes >= 60 && minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      if (hours <= 99) return (hours, AlarmUnit.hours);
    }
    if (minutes >= 1440 && minutes % 1440 == 0) {
      final days = minutes ~/ 1440;
      if (days <= 99) return (days, AlarmUnit.days);
    }
    return (minutes.clamp(0, 99), AlarmUnit.minutes);
  }

  /// 사전 정의된 알림 옵션 (분, 라벨)
  static const predefinedOptions = [
    (0, '일정 시작'),
    (5, '5분 전'),
    (10, '10분 전'),
    (60, '1시간 전'),
    (1440, '1일 전'),
  ];

  static const predefinedMinutes = [0, 5, 10, 60, 1440];
}

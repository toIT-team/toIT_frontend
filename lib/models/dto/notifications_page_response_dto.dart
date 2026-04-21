// GET /page/notifications 응답 및 알림 항목 DTO

/// 서버 `type` 문자열과 매핑되는 알림 유형
enum NotificationType {
  /// 일정 (SCHEDULE)
  schedule('SCHEDULE', '일정'),

  /// 피드백 답변 (FEEDBACK_REPLY)
  feedbackReply('FEEDBACK_REPLY', '피드백 답변'),

  /// 공지사항 (NOTICE)
  notice('NOTICE', '공지사항');

  const NotificationType(this.apiValue, this.labelKo);

  /// API JSON `type` 필드 값
  final String apiValue;

  /// UI에 표시할 한글 라벨
  final String labelKo;

  /// API 문자열 → enum, 알 수 없으면 null
  static NotificationType? tryParseApi(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final v in NotificationType.values) {
      if (v.apiValue == raw) return v;
    }
    return null;
  }
}

/// 단일 알림 항목
class NotificationItemDto {
  const NotificationItemDto({
    required this.notificationId,
    required this.title,
    required this.type,
    required this.deeplink,
    required this.isRead,
  });

  final int notificationId;
  final String title;
  final NotificationType type;
  final String deeplink;
  final bool isRead;

  factory NotificationItemDto.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'] as String?;
    final type = NotificationType.tryParseApi(typeRaw);
    if (type == null) {
      throw FormatException('Unknown notification type: $typeRaw');
    }
    final id = json['notificationId'];
    final notificationId = id is int
        ? id
        : int.tryParse(id?.toString() ?? '') ?? -1;
    return NotificationItemDto(
      notificationId: notificationId,
      title: (json['title'] as String?)?.trim() ?? '',
      type: type,
      deeplink: (json['deeplink'] as String?)?.trim() ?? '',
      isRead: json['isRead'] as bool? ?? true,
    );
  }
}

/// 알림 페이지 전체 응답
class NotificationsPageResponseDto {
  const NotificationsPageResponseDto({required this.notifications});

  final List<NotificationItemDto> notifications;

  factory NotificationsPageResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = json['notifications'];
    if (raw is! List<dynamic>) {
      return const NotificationsPageResponseDto(notifications: []);
    }
    final items = <NotificationItemDto>[];
    for (final e in raw) {
      if (e is! Map<String, dynamic>) continue;
      try {
        items.add(NotificationItemDto.fromJson(e));
      } on FormatException {
        continue;
      }
    }
    return NotificationsPageResponseDto(notifications: items);
  }
}

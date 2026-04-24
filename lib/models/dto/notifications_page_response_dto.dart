// GET /page/notifications 응답 및 알림 항목 DTO
//
// 루트: `{ notifications: [...] }` 또는 `{ data: { notifications: [...] } }`
// 항목: notificationId, title, type, deeplink,
// sentAt 또는 sent_at(ISO 8601·필수), isRead 또는 is_read(bool|0|1)

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

  /// `deeplink`가 없을 때(원본 삭제 등) 모달에 쓰는 안내 문구
  String get missingDeeplinkBodyKo {
    return switch (this) {
      NotificationType.schedule =>
        '해당 일정은 존재하지 않습니다.\n'
            '일정이 삭제되었을 수 있습니다.',
      NotificationType.feedbackReply =>
        '해당 문의 답변 내역은 존재하지 않습니다.\n'
            '삭제되었을 수 있습니다.',
      NotificationType.notice =>
        '해당 공지는 존재하지 않습니다.\n'
            '삭제되었을 수 있습니다.',
    };
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
    required this.sentAt,
  });

  final int notificationId;
  final String title;
  final NotificationType type;
  final String deeplink;
  final bool isRead;

  /// 발송 시각 (로컬). API `sentAt`(ISO 8601) — 알림마다 반드시 있음
  final DateTime sentAt;

  static DateTime? _parseSentAt(dynamic v) {
    if (v == null) return null;
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      var parsed = DateTime.tryParse(s);
      if (parsed != null) return parsed.toLocal();
      // "yyyy-MM-dd HH:mm:ss" 등 공백 구분
      if (s.contains(' ') && !s.contains('T')) {
        parsed = DateTime.tryParse(s.replaceFirst(' ', 'T'));
        if (parsed != null) return parsed.toLocal();
      }
      return null;
    }
    if (v is int && v > 2000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
    }
    return null;
  }

  static bool _parseIsRead(dynamic v) {
    if (v == null) return true;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final lower = v.toLowerCase();
      return lower != 'false' && lower != '0';
    }
    return true;
  }

  NotificationItemDto copyWith({
    int? notificationId,
    String? title,
    NotificationType? type,
    String? deeplink,
    bool? isRead,
    DateTime? sentAt,
  }) {
    return NotificationItemDto(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      type: type ?? this.type,
      deeplink: deeplink ?? this.deeplink,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  /// 목록 부제: 오늘 발송이면 `오늘`, 아니면 `yyyy.MM.dd`
  String get listSubtitleKo {
    final local = sentAt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return '오늘';
    final y = local.year;
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  factory NotificationItemDto.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'] as String?;
    final type = NotificationType.tryParseApi(typeRaw);
    if (type == null) {
      throw FormatException('Unknown notification type: $typeRaw');
    }
    final parsedSentAt = _parseSentAt(json['sentAt'] ?? json['sent_at']);
    if (parsedSentAt == null) {
      throw FormatException('Missing or invalid sentAt');
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
      isRead: _parseIsRead(json['isRead'] ?? json['is_read']),
      sentAt: parsedSentAt,
    );
  }
}

/// 알림 페이지 전체 응답
class NotificationsPageResponseDto {
  const NotificationsPageResponseDto({required this.notifications});

  final List<NotificationItemDto> notifications;

  NotificationsPageResponseDto copyWith({
    List<NotificationItemDto>? notifications,
  }) {
    return NotificationsPageResponseDto(
      notifications: notifications ?? this.notifications,
    );
  }

  /// 최상단 또는 `data` 안의 `notifications` 배열을 사용
  static Map<String, dynamic> _notificationsRoot(Map<String, dynamic> json) {
    if (json.containsKey('notifications')) return json;
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return json;
  }

  static Map<String, dynamic>? _elementAsMap(dynamic e) {
    if (e is Map<String, dynamic>) return e;
    if (e is Map) return Map<String, dynamic>.from(e);
    return null;
  }

  factory NotificationsPageResponseDto.fromJson(Map<String, dynamic> json) {
    final root = _notificationsRoot(json);
    final raw = root['notifications'];
    if (raw is! List<dynamic>) {
      return const NotificationsPageResponseDto(notifications: []);
    }
    final items = <NotificationItemDto>[];
    for (final e in raw) {
      final row = _elementAsMap(e);
      if (row == null) continue;
      try {
        items.add(NotificationItemDto.fromJson(row));
      } on FormatException {
        continue;
      }
    }
    return NotificationsPageResponseDto(notifications: items);
  }
}

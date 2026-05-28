/// GET /api/notifications/unread-count 응답 DTO
class NotificationsUnreadCountResponseDto {
  const NotificationsUnreadCountResponseDto({required this.unreadCount});

  final int unreadCount;

  factory NotificationsUnreadCountResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final root = _extractRoot(json);
    final rawCount = root['unreadCount'];
    final parsedCount = switch (rawCount) {
      int value => value,
      String value => int.tryParse(value.trim()) ?? 0,
      _ => 0,
    };
    return NotificationsUnreadCountResponseDto(
      unreadCount: parsedCount < 0 ? 0 : parsedCount,
    );
  }

  static Map<String, dynamic> _extractRoot(Map<String, dynamic> json) {
    if (json.containsKey('unreadCount')) {
      return json;
    }
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return json;
  }
}

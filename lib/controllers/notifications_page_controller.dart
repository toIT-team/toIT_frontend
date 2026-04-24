import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/dto/notifications_page_response_dto.dart';

Future<NotificationsPageResponseDto> _fetchNotificationsPage(Ref ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiConstants.notificationsEndpoint);
  final body = response.data;
  final Map<String, dynamic> jsonMap;
  if (body is Map<String, dynamic>) {
    jsonMap = body;
  } else if (body is Map) {
    jsonMap = Map<String, dynamic>.from(body);
  } else if (body is List<dynamic>) {
    jsonMap = <String, dynamic>{'notifications': body};
  } else {
    throw StateError(
      'Unexpected /page/notifications body: ${body.runtimeType}',
    );
  }
  return NotificationsPageResponseDto.fromJson(jsonMap);
}

/// 알림 목록 (GET) + 탭 시 읽음 PATCH, 로컬 먼저 반영
class NotificationsPageNotifier
    extends StateNotifier<AsyncValue<NotificationsPageResponseDto>> {
  NotificationsPageNotifier(this._ref, this._cacheKey)
    : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  final (int, int) _cacheKey;

  Future<void> _load() async {
    final (_, refreshTick) = _cacheKey;
    if (refreshTick < 0) {
      state = AsyncValue.error(
        StateError('Invalid refresh tick: $refreshTick'),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotificationsPage(_ref));
  }

  /// 당김 새로고침·에러 재시도
  Future<void> refresh() async {
    await _load();
  }

  /// 미읽음이면 UI를 즉시 읽음으로 바꾼 뒤 PATCH (실패 시 롤백)
  void scheduleMarkReadIfUnread(int notificationId) {
    final data = state.value;
    if (data == null) return;

    NotificationItemDto? target;
    for (final n in data.notifications) {
      if (n.notificationId == notificationId) {
        target = n;
        break;
      }
    }
    if (target == null || target.isRead) return;

    final previous = data;
    final updated = previous.copyWith(
      notifications: [
        for (final n in previous.notifications)
          if (n.notificationId == notificationId)
            n.copyWith(isRead: true)
          else
            n,
      ],
    );
    state = AsyncValue.data(updated);

    Future(() async {
      try {
        await _ref
            .read(apiClientProvider)
            .patch<void>(ApiConstants.notificationReadPath(notificationId));
      } catch (_) {
        try {
          state = AsyncValue.data(previous);
        } on Object {
          // Provider 해제 직후 등 상태 반영 불가 시 무시
        }
      }
    });
  }
}

/// 세션·사용자 전환 시 `cacheKey`로 캐시 분리
final notificationsPageProvider =
    StateNotifierProvider.family<
      NotificationsPageNotifier,
      AsyncValue<NotificationsPageResponseDto>,
      (int, int)
    >((ref, key) {
      return NotificationsPageNotifier(ref, key);
    });

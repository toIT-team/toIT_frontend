import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/dto/notifications_page_response_dto.dart';
import 'notifications_unread_count_controller.dart';

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

/// 알림 목록 캐시가 신선하지 않다는 외부 신호.
///
/// 포그라운드 FCM 수신·앱 resume 등 "리스트가 변했을 가능성"이 있는 시점에
/// `true`로 올려둔다. 알림 페이지가 떠 있으면 즉시 동기화되고, 떠 있지 않으면
/// 다음 진입 시 [NotificationsPageNotifier.maybeRefresh]가 소비한다.
final notificationsPageDirtyProvider =
    StateProvider.family<bool, (int, int)>((ref, _) => false);

/// 알림 목록 (GET) + 탭 시 읽음 PATCH, 로컬 먼저 반영
class NotificationsPageNotifier
    extends StateNotifier<AsyncValue<NotificationsPageResponseDto>> {
  NotificationsPageNotifier(this._ref, this._cacheKey)
    : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  final (int, int) _cacheKey;

  /// 마지막으로 서버에서 받아온 시각. 진입 시 TTL 기반 재조회 판단에 사용.
  DateTime? _lastSyncedAt;

  /// 동시에 여러 트리거가 들어올 때 중복 호출을 막는다.
  bool _isFetching = false;

  /// 외부 신호(dirty)가 없어도 이 시간이 지났으면 캐시를 stale로 본다.
  /// 백그라운드 알림이 누락된 케이스를 보강하기 위한 안전망.
  static const Duration _staleTtl = Duration(minutes: 5);

  Future<void> _load() async {
    final (_, refreshTick) = _cacheKey;
    if (refreshTick < 0) {
      state = AsyncValue.error(
        StateError('Invalid refresh tick: $refreshTick'),
        StackTrace.current,
      );
      return;
    }
    if (_isFetching) return;
    _isFetching = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotificationsPage(_ref));
    if (state.hasValue) {
      _lastSyncedAt = DateTime.now();
    }
    _clearDirtyFlag();
    _isFetching = false;
  }

  /// 당김 새로고침·에러 재시도
  Future<void> refresh() async {
    await _load();
  }

  /// 캐시가 dirty거나 TTL을 초과한 경우에만 서버를 다시 부른다.
  ///
  /// 알림 페이지 진입 시 호출하는 SWR 진입점. 매 진입마다 fetch하지 않으므로
  /// 사용자가 화면을 빠르게 드나들어도 추가 비용이 거의 없다.
  Future<void> maybeRefresh({Duration ttl = _staleTtl}) async {
    if (_isFetching) return;
    final isDirty = _ref.read(notificationsPageDirtyProvider(_cacheKey));
    final lastSyncedAt = _lastSyncedAt;
    final isStale =
        lastSyncedAt != null && DateTime.now().difference(lastSyncedAt) >= ttl;
    if (!isDirty && !isStale) return;
    await _load();
  }

  void _clearDirtyFlag() {
    final notifier =
        _ref.read(notificationsPageDirtyProvider(_cacheKey).notifier);
    if (notifier.state) notifier.state = false;
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
    _ref
        .read(notificationsUnreadCountProvider(_cacheKey).notifier)
        .consumeOneUnreadOptimistic();

    Future(() async {
      try {
        await _ref
            .read(apiClientProvider)
            .patch<void>(ApiConstants.notificationReadPath(notificationId));
      } catch (_) {
        try {
          state = AsyncValue.data(previous);
          _ref
              .read(notificationsUnreadCountProvider(_cacheKey).notifier)
              .restoreOneUnreadOnFailure();
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/dto/notifications_unread_count_response_dto.dart';

Future<NotificationsUnreadCountResponseDto> _fetchUnreadCount(Ref ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(
    ApiConstants.notificationsUnreadCountEndpoint,
  );
  final body = response.data;
  final Map<String, dynamic> jsonMap;
  if (body is Map<String, dynamic>) {
    jsonMap = body;
  } else if (body is Map) {
    jsonMap = Map<String, dynamic>.from(body);
  } else {
    throw StateError(
      'Unexpected /api/notifications/unread-count body: '
      '${body.runtimeType}',
    );
  }
  return NotificationsUnreadCountResponseDto.fromJson(jsonMap);
}

class NotificationsUnreadCountNotifier extends StateNotifier<AsyncValue<int>> {
  NotificationsUnreadCountNotifier(this._ref, this._cacheKey)
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
    state = await AsyncValue.guard(() async {
      final dto = await _fetchUnreadCount(_ref);
      return dto.unreadCount;
    });
  }

  Future<void> refresh() async {
    await _load();
  }

  void consumeOneUnreadOptimistic() {
    final value = state.value;
    if (value == null) return;
    state = AsyncValue.data(value > 0 ? value - 1 : 0);
  }

  void restoreOneUnreadOnFailure() {
    final value = state.value;
    if (value == null) return;
    state = AsyncValue.data(value + 1);
  }
}

final notificationsUnreadCountProvider =
    StateNotifierProvider.family<
      NotificationsUnreadCountNotifier,
      AsyncValue<int>,
      (int, int)
    >((ref, key) {
      return NotificationsUnreadCountNotifier(ref, key);
    });

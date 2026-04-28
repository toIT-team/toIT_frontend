import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/notifications_page_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/system_safe_area.dart';
import '../widgets/notification/notification_list.dart';
import 'notification_settings_screen.dart';

/// 알림 목록 화면
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // 첫 빌드 직후, dirty 또는 TTL 초과인 경우에만 서버에서 재조회한다.
    // 매 진입마다 강제 fetch하지 않으므로 짧은 간격의 진출입에는 비용이 없다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeRefreshIfNeeded();
    });
  }

  void _maybeRefreshIfNeeded() {
    final cacheKey = _resolveCacheKey();
    if (cacheKey == null) return;
    _triggerMaybeRefresh(cacheKey);
  }

  (int, int)? _resolveCacheKey() {
    final auth = ref.read(authProvider);
    final userId = auth.userId;
    if (auth.status != AuthStatus.authenticated || userId == null) return null;
    return (userId, ref.read(authSessionRefreshTickProvider));
  }

  /// dirty/TTL을 내부에서 검사한 뒤 필요할 때만 fetch한다.
  /// 반환된 Future를 의도적으로 버려도 괜찮음을 호출 지점에서 알리는 래퍼.
  void _triggerMaybeRefresh((int, int) cacheKey) {
    // ignore: discarded_futures
    ref.read(notificationsPageProvider(cacheKey).notifier).maybeRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider.select((s) => s.userId));
    if (userId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SystemSafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    final refreshTick = ref.watch(authSessionRefreshTickProvider);
    final cacheKey = (userId, refreshTick);

    // 화면이 떠 있는 동안 새 알림이 도착하면 dirty=true가 되고,
    // 즉시 백그라운드 동기화로 리스트가 자연스럽게 갱신된다.
    ref.listen<bool>(notificationsPageDirtyProvider(cacheKey), (_, isDirty) {
      if (!isDirty) return;
      _triggerMaybeRefresh(cacheKey);
    });

    final pageAsync = ref.watch(notificationsPageProvider(cacheKey));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SystemSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NotificationHeader(
              onSettingPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            Expanded(
              child: pageAsync.when(
                data: (page) =>
                    NotificationList(cacheKey: cacheKey, page: page),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorView(
                  message: '알림을 불러오지 못했습니다.\n$error',
                  onRetry: () =>
                      ref.invalidate(notificationsPageProvider(cacheKey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({required this.onSettingPressed});

  final VoidCallback onSettingPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.chevron_left,
              size: 28,
              color: AppColors.gray900,
            ),
          ),
          const Text(
            '알림',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onSettingPressed,
            icon: SvgPicture.asset(
              AppAssets.settingIcon,
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.gray600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

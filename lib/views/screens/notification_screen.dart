import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/notifications_page_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/notification/notification_list.dart';
import 'notification_settings_screen.dart';

/// 알림 목록 화면
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider.select((s) => s.userId));
    if (userId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    final refreshTick = ref.watch(authSessionRefreshTickProvider);
    final cacheKey = (userId, refreshTick);
    final pageAsync = ref.watch(notificationsPageProvider(cacheKey));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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

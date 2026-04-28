import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/notifications_unread_count_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_assets.dart';

/// 홈/캘린더 등 공통 상단 앱바
class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({
    super.key,
    this.title = '마이',
    this.onMenuPressed,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.useLightStatusBar = false,
  });

  final String title;

  /// `true`면 희미한 아이콘(흰색) — 그라데이션/어두운 상단 배경용(홈).
  /// `false`면 어두운 아이콘 — 밝은 배경용(캘린더).
  final bool useLightStatusBar;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider.select((state) => state.userId));
    final refreshTick = ref.watch(authSessionRefreshTickProvider);
    final unreadCountAsync = userId == null
        ? const AsyncValue<int>.data(0)
        : ref.watch(notificationsUnreadCountProvider((userId, refreshTick)));
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;
    final hasUnread = unreadCount > 0;
    final badgeText = unreadCount > 99 ? '99+' : '$unreadCount';
    final systemOverlay = useLightStatusBar
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          );
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: systemOverlay,
      titleSpacing: AppSpacing.md,
      title: Row(
        children: [
          IconButton(
            onPressed: onMenuPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 24, height: 24),
            icon: const Icon(Icons.menu, color: AppColors.gray900),
          ),
          const SizedBox(width: 0),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Image.asset(AppAssets.searchIcon, width: 24, height: 24),
            onPressed: onSearchPressed,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Image.asset(
                  AppAssets.notificationIcon,
                  width: 24,
                  height: 24,
                ),
                onPressed: onNotificationPressed,
              ),
              if (hasUnread)
                Positioned(
                  right: 4,
                  top: 6,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.badge,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

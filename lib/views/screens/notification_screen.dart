import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/deep_link/toit_deep_link_opener.dart';
import '../../core/network/api_client.dart';
import '../../models/dto/notifications_page_response_dto.dart';
import 'notification_settings_screen.dart';

/// GET /page/notifications 결과 Provider (세션·사용자 전환 시 캐시 분리)
final notificationsPageProvider =
    FutureProvider.family<NotificationsPageResponseDto, (int, int)>((
      ref,
      key,
    ) async {
      final (_, refreshTick) = key;
      if (refreshTick < 0) {
        throw StateError('Invalid refresh tick: $refreshTick');
      }
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiConstants.notificationsEndpoint);
      return NotificationsPageResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    });

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
                    _NotificationsBody(cacheKey: cacheKey, page: page),
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

class _NotificationsBody extends ConsumerWidget {
  const _NotificationsBody({required this.cacheKey, required this.page});

  final (int, int) cacheKey;
  final NotificationsPageResponseDto page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = page.notifications
        .where((e) => !e.isRead)
        .toList(growable: false);
    final read = page.notifications
        .where((e) => e.isRead)
        .toList(growable: false);

    if (unread.isEmpty && read.isEmpty) {
      return RefreshIndicator(
        color: AppColors.blue500,
        onRefresh: () => _onRefresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                '알림이 없습니다.',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.blue500,
      onRefresh: () => _onRefresh(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (unread.isNotEmpty) ...[
            const _SectionLabel(title: '새로운 알림'),
            _NotificationSection(items: unread),
          ],
          if (unread.isNotEmpty && read.isNotEmpty) const _SectionDivider(),
          if (read.isNotEmpty) ...[
            const _SectionLabel(title: '지난 알림'),
            _NotificationSection(items: read),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(notificationsPageProvider(cacheKey));
    await ref.read(notificationsPageProvider(cacheKey).future);
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.neutral300,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.gray600,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }
}

class _NotificationSection extends ConsumerWidget {
  const _NotificationSection({required this.items});

  final List<NotificationItemDto> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastIndex = items.length - 1;
    return Column(
      children: items.asMap().entries.map((entry) {
        return _NotificationCard(
          item: entry.value,
          showBottomDivider: entry.key != lastIndex,
          onOpenDeeplink: () => _openItem(context, ref, entry.value),
        );
      }).toList(),
    );
  }

  Future<void> _openItem(
    BuildContext context,
    WidgetRef ref,
    NotificationItemDto item,
  ) async {
    final link = item.deeplink.trim();
    if (link.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이동할 링크가 없습니다.')));
      }
      return;
    }
    await ToitDeepLinkOpener.open(ref, context, link);
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(height: 10, color: AppColors.neutral300),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.showBottomDivider,
    required this.onOpenDeeplink,
  });

  final NotificationItemDto item;
  final bool showBottomDivider;
  final VoidCallback onOpenDeeplink;

  @override
  Widget build(BuildContext context) {
    final rowBg = item.isRead
        ? Colors.white
        : AppColors.gradientLightBlue.withValues(alpha: 0.45);

    return Material(
      color: rowBg,
      child: InkWell(
        onTap: onOpenDeeplink,
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: showBottomDivider ? 16 : 0,
          ),
          decoration: BoxDecoration(
            border: showBottomDivider
                ? const Border(bottom: BorderSide(color: AppColors.neutral50))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationTypeIcon(type: item.type),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? '(제목 없음)' : item.title,
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.type.labelKo,
                      style: const TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTypeIcon extends StatelessWidget {
  const _NotificationTypeIcon({required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final path = switch (type) {
      NotificationType.schedule => AppAssets.searchResultEventIcon,
      NotificationType.feedbackReply => AppAssets.notificationFeedbackIcon,
      NotificationType.notice => AppAssets.notificationNoticeIcon,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral50),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Center(
        child: SvgPicture.asset(
          path,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/notifications_page_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/deep_link/toit_deep_link_opener.dart';
import '../../../models/dto/notifications_page_response_dto.dart';
import '../common/app_alert_dialog.dart';
import 'notification_list_item.dart';

/// 알림 목록 본문 (섹션 + [NotificationListItem] 나열)
class NotificationList extends ConsumerWidget {
  const NotificationList({
    super.key,
    required this.cacheKey,
    required this.page,
  });

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
            _NotificationSection(cacheKey: cacheKey, items: unread),
          ],
          if (unread.isNotEmpty && read.isNotEmpty) const _SectionDivider(),
          if (read.isNotEmpty) ...[
            const _SectionLabel(title: '지난 알림'),
            _NotificationSection(cacheKey: cacheKey, items: read),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _onRefresh(WidgetRef ref) async {
    await ref.read(notificationsPageProvider(cacheKey).notifier).refresh();
  }
}

/// 피그마: 회색 띠 없이 좌측 정렬 텍스트만
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.gray600,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}

/// 새로운 알림 / 지난 알림 사이 구분 (가로 전체, 높이 10)
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  static const double _height = 10;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: _height,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.neutral300,
          ),
        ),
      ),
    );
  }
}

class _NotificationSection extends ConsumerWidget {
  const _NotificationSection({required this.cacheKey, required this.items});

  final (int, int) cacheKey;
  final List<NotificationItemDto> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastIndex = items.length - 1;
    return Column(
      children: items.asMap().entries.map((entry) {
        return NotificationListItem(
          item: entry.value,
          showBottomDivider: entry.key != lastIndex,
          onTap: () => _openItem(context, ref, cacheKey, entry.value),
        );
      }).toList(),
    );
  }

  Future<void> _openItem(
    BuildContext context,
    WidgetRef ref,
    (int, int) cacheKey,
    NotificationItemDto item,
  ) async {
    ref
        .read(notificationsPageProvider(cacheKey).notifier)
        .scheduleMarkReadIfUnread(item.notificationId);

    final link = item.deeplink.trim();
    if (link.isEmpty) {
      if (context.mounted) {
        await showAppAlertDialog(
          context,
          message: item.type.missingDeeplinkBodyKo,
        );
      }
      return;
    }
    await ToitDeepLinkOpener.open(ref, context, link);
  }
}

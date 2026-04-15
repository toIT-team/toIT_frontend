import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import 'notification_settings_screen.dart';

/// 알림 화면 (UI 퍼블리싱 전용)
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
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
            SizedBox(height: 16),
            const _SectionLabel(title: '새로운 알림'),
            const _NotificationSection(items: _newNotifications),
            const _SectionDivider(),
            const _SectionLabel(title: '지난 알림'),
            const _NotificationSection(items: _oldNotifications),
            const SizedBox(height: 24),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({required this.items});

  final List<_NotificationItemData> items;

  @override
  Widget build(BuildContext context) {
    final lastIndex = items.length - 1;
    return Column(
      children: items.asMap().entries.map((entry) {
        return _NotificationCard(
          item: entry.value,
          showBottomDivider: entry.key != lastIndex,
        );
      }).toList(),
    );
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
  });

  final _NotificationItemData item;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const _NotificationCategoryFrame(),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.dateText,
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
    );
  }
}

class _NotificationCategoryFrame extends StatelessWidget {
  const _NotificationCategoryFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral50),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _NotificationItemData {
  const _NotificationItemData({required this.title, required this.dateText});

  final String title;
  final String dateText;
}

const List<_NotificationItemData> _newNotifications = [
  _NotificationItemData(title: '김상우 바봉.', dateText: '오늘'),
  _NotificationItemData(title: '시각디자인 설명회가 시작되었어요.', dateText: '오늘'),
  _NotificationItemData(title: '시각디자인 설명회가 시작되었어요.', dateText: '오늘'),
  _NotificationItemData(
    title: '시각디자인 설명회가 시작되었어요.시각디자인 설명회가 시작되었어요.',
    dateText: '오늘',
  ),
];

const List<_NotificationItemData> _oldNotifications = [
  _NotificationItemData(
    title: '[공지] ‘투잇’ 서비스가 런칭 되었습니다.',
    dateText: '2026.01.02',
  ),
  _NotificationItemData(title: '시각디자인 설명회가 시작되었어요.', dateText: '2026.01.02'),
  _NotificationItemData(
    title: '[문의] ‘동영상은 업로드 안되나요?’ 답변이 등록되었습니다.',
    dateText: '2025.12.26',
  ),
];

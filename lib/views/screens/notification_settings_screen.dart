import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// 알림 설정 화면 (UI + 토글 동작)
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool isAppNotificationEnabled = true;
  bool isScheduleNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _NotificationSettingsHeader(),
            const SizedBox(height: 16),
            _NotificationSettingRow(
              title: '앱 전체 알림',
              value: isAppNotificationEnabled,
              hasBottomDivider: true,
              onChanged: (nextValue) {
                setState(() {
                  isAppNotificationEnabled = nextValue;
                });
              },
            ),
            _NotificationSettingRow(
              title: '일정 알림',
              value: isScheduleNotificationEnabled,
              onChanged: (nextValue) {
                setState(() {
                  isScheduleNotificationEnabled = nextValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSettingsHeader extends StatelessWidget {
  const _NotificationSettingsHeader();

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
        ],
      ),
    );
  }
}

class _NotificationSettingRow extends StatelessWidget {
  const _NotificationSettingRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.hasBottomDivider = false,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool hasBottomDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: hasBottomDivider
            ? const Border(bottom: BorderSide(color: AppColors.neutral50))
            : null,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const Spacer(),
          _NotificationToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? AppColors.blue500 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            if (!value) const Spacer(),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            if (value) const Spacer(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/system_safe_area.dart';
import '../widgets/common/app_snack_bar.dart';

/// 알림 설정 화면 (앱 전체 알림 ↔ 서버 동기화)
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool isAppNotificationEnabled = true;
  bool isPatchingAlarmSetting = false;

  Future<void> patchAppAlarmEnabled(bool nextValue) async {
    if (isPatchingAlarmSetting) return;

    final previous = isAppNotificationEnabled;
    setState(() {
      isAppNotificationEnabled = nextValue;
      isPatchingAlarmSetting = true;
    });

    try {
      await ref.read(apiClientProvider).patch<void>(
            ApiConstants.usersAlarmSettingEndpoint,
            data: {'appAlarmEnabled': nextValue},
          );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isAppNotificationEnabled = previous;
      });
      showAppSnackBar(context, '알림 설정 저장에 실패했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          isPatchingAlarmSetting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SystemSafeArea(
        child: Column(
          children: [
            const _NotificationSettingsHeader(),
            const SizedBox(height: 16),
            IgnorePointer(
              ignoring: isPatchingAlarmSetting,
              child: Opacity(
                opacity: isPatchingAlarmSetting ? 0.5 : 1,
                child: _NotificationSettingRow(
                  title: '앱 전체 알림',
                  value: isAppNotificationEnabled,
                  onChanged: patchAppAlarmEnabled,
                ),
              ),
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
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 20),
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

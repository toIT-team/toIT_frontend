import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import 'search_screen.dart';
import 'my_screen.dart';
import 'notification_screen.dart';
import '../widgets/calendar/calendar_widget.dart';
import '../widgets/home/home_app_bar.dart';

/// 캘린더 화면
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  void _openMy(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MyScreen()));
  }

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: HomeAppBar(
          title: '캘린더',
          onMenuPressed: () => _openMy(context),
          onSearchPressed: () => _openSearch(context),
          onNotificationPressed: () => _openNotifications(context),
        ),
      ),
      body: const CalendarWidget(),
    );
  }
}

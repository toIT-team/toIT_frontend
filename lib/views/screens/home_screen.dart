import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/system_safe_area.dart';
import '../../core/constants/app_gradients.dart';
import 'my_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/greeting_section.dart';
import '../widgets/home/folder_section.dart';

/// 메인 홈 화면
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.homeBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: HomeAppBar(
            useLightStatusBar: true,
            onMenuPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const MyScreen()));
            },
            onSearchPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
              );
            },
            onNotificationPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
          ),
        ),
        body: homeState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SystemSafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreetingSection(
                        userName: homeState.userName,
                        todayScheduleCount: homeState.todayScheduleCount,
                        schedules: homeState.schedules,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FolderSection(
                        folders: homeState.folders,
                        filters: homeState.filters,
                      ),
                      // 하단 네비바 공간 확보
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

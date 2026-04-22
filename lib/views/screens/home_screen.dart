import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
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
            onMenuPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const MyScreen()));
            },
            onSearchPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SearchScreen(),
                ),
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
            : SafeArea(
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
                      const SizedBox(height: 16),
                      // TODO: 테스트용 카카오 로그인 버튼 (추후 삭제)
                      _buildTestLoginButton(ref),
                      // 하단 네비바 공간 확보
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// 테스트용 카카오 로그인 버튼 (추후 삭제)
  Widget _buildTestLoginButton(WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton.icon(
        onPressed: () {
          if (isLoggedIn) {
            ref.read(authProvider.notifier).logout();
          } else {
            ref.read(authProvider.notifier).loginWithKakao();
          }
        },
        icon: Icon(isLoggedIn ? Icons.logout : Icons.login, size: 18),
        label: Text(
          isLoggedIn ? '로그아웃 (테스트)' : '카카오 로그인 (테스트)',
          style: const TextStyle(fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gray600,
          side: const BorderSide(color: AppColors.neutral100),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_assets.dart';

/// 홈 화면 상단 앱바
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleSpacing: AppSpacing.md,
      title: Row(
        children: [
          const Icon(Icons.menu, color: AppColors.gray900),
          const SizedBox(width: AppSpacing.sm),
          const Text(
            '마이',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Image.asset(AppAssets.searchIcon, width: 24, height: 24),
            onPressed: () {},
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
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.badge,
                    shape: BoxShape.circle,
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

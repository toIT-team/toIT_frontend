import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_assets.dart';

/// 폴더 타일 위젯
class FolderTile extends StatelessWidget {
  final String title;
  final String countText;
  final Color accentColor;

  const FolderTile({
    super.key,
    required this.title,
    required this.countText,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final colorBoxBottom = height * 0.35; // 하단 35% 남기기
            final overlayTop = height * 0.25;
            final overlayBottom = height * 0.2;

            return Stack(
              children: [
                // 상단 컬러 박스
                Positioned(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: colorBoxBottom,
                  child: Container(
                    decoration: BoxDecoration(
                      color: accentColor,
                      boxShadow: const [
                        BoxShadow(color: Color(0x0F132145), blurRadius: 8),
                      ],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                // 유리 느낌의 흰색 오버레이 (블러)
                Positioned(
                  left: 8,
                  right: 8,
                  top: overlayTop,
                  bottom: overlayBottom,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: const Color(0xE6FFFFFF)),
                    ),
                  ),
                ),
                // 폴더 아이콘
                Positioned(
                  left: 14,
                  top: 12,
                  child: Image.asset(AppAssets.folderIcon, width: 22, height: 22),
                ),
                // 내용
                Positioned(
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.25,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            countText,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.25,
                              height: 1.2,
                            ),
                          ),
                          Image.asset(AppAssets.moreIcon, width: 24, height: 14),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

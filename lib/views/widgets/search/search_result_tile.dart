import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/search_assets.dart';
import '../../../models/search/search_result_item.dart';

/// 검색 결과 타일
///
/// 타입별 좌측 아이콘 + 우측 제목/부제목
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final SearchResultItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIconArea(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                      letterSpacing: -0.025 * 18,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray600,
                      letterSpacing: -0.025 * 14,
                      height: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconArea() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Center(child: _iconForResult()),
    );
  }

  Widget _iconForResult() {
    switch (item.type) {
      case SearchResultType.folder:
        return Image.asset(
          AppAssets.folderIcon,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        );
      case SearchResultType.schedule:
        return SvgPicture.asset(
          SearchAssets.resultEvent,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        );
      case SearchResultType.link:
        return SvgPicture.asset(
          SearchAssets.resultLink,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        );
      case SearchResultType.note:
        return SvgPicture.asset(
          SearchAssets.resultText,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        );
      case SearchResultType.file:
        return SvgPicture.asset(
          SearchAssets.resultFile,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        );
      case SearchResultType.image:
        return SvgPicture.asset(
          SearchAssets.resultImage,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        );
    }
  }
}

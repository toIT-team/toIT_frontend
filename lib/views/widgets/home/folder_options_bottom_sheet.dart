import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

/// 보관함 옵션 바텀시트 반환값
enum FolderOption { viewMemo, edit, toggleFavorite, delete }

/// 보관함 케밥 메뉴 바텀시트 표시
Future<FolderOption?> showFolderOptionsBottomSheet(
  BuildContext context, {
  required bool isFavorite,
}) {
  return showModalBottomSheet<FolderOption>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.gray900.withOpacity(0.2),
    builder: (context) => _FolderOptionsSheet(isFavorite: isFavorite),
  );
}

class _FolderOptionsSheet extends StatelessWidget {
  final bool isFavorite;

  const _FolderOptionsSheet({required this.isFavorite});

  static const String _filledFavoriteIconSvg = '''
<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M14.1667 2.5C14.6088 2.5 15.0327 2.67559 15.3453 2.98816C15.6578 3.30072 15.8334 3.72464 15.8334 4.16667V16.6667C15.8334 16.8126 15.795 16.956 15.7221 17.0824C15.6493 17.2089 15.5445 17.314 15.4183 17.3872C15.2921 17.4604 15.1488 17.4992 15.0029 17.4997C14.857 17.5002 14.7135 17.4624 14.5867 17.39L10.8267 15.2417C10.575 15.0978 10.29 15.0222 10.0001 15.0222C9.71013 15.0222 9.42519 15.0978 9.17342 15.2417L5.41341 17.39C5.2867 17.4624 5.1432 17.5002 4.99727 17.4997C4.85133 17.4992 4.70809 17.4604 4.58187 17.3872C4.45564 17.314 4.35086 17.2089 4.27801 17.0824C4.20516 16.956 4.1668 16.8126 4.16675 16.6667V4.16667C4.16675 3.72464 4.34234 3.30072 4.6549 2.98816C4.96746 2.67559 5.39139 2.5 5.83341 2.5H14.1667Z" fill="#80839C" stroke="#80839C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.neutral50)),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayScrim,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _buildDragHandle(),
            _OptionItem(
              iconAssetPath: AppAssets.editFolderIcon,
              isSvgIcon: true,
              iconTintColor: AppColors.gray600,
              iconWidth: 20,
              iconHeight: 20,
              label: '보관함 수정',
              textColor: AppColors.gray900,
              onTap: () => Navigator.pop(context, FolderOption.edit),
            ),
            _OptionItem(
              iconAssetPath: AppAssets.folderMemoIcon,
              isSvgIcon: true,
              iconTintColor: AppColors.gray600,
              iconWidth: 20,
              iconHeight: 20,
              label: '보관함 메모 보기',
              textColor: AppColors.gray900,
              onTap: () => Navigator.pop(context, FolderOption.viewMemo),
            ),
            _OptionItem(
              iconAssetPath: AppAssets.favoriteIcon,
              isSvgIcon: true,
              iconTintColor: AppColors.gray600,
              iconWidth: 20,
              iconHeight: 20,
              customIcon: isFavorite
                  ? SvgPicture.string(
                      _filledFavoriteIconSvg,
                      width: 20,
                      height: 20,
                    )
                  : null,
              label: isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
              textColor: AppColors.gray900,
              onTap: () => Navigator.pop(context, FolderOption.toggleFavorite),
            ),
            _OptionItem(
              iconAssetPath: AppAssets.bottomSheetDeleteIcon,
              isSvgIcon: false,
              iconWidth: 20,
              iconHeight: 20,
              label: '삭제',
              textColor: AppColors.red500,
              onTap: () => Navigator.pop(context, FolderOption.delete),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 42,
        height: 3,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String iconAssetPath;
  final bool isSvgIcon;
  final Color? iconTintColor;
  final double iconWidth;
  final double iconHeight;
  final Widget? customIcon;
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  const _OptionItem({
    required this.iconAssetPath,
    required this.isSvgIcon,
    this.iconTintColor,
    required this.iconWidth,
    required this.iconHeight,
    this.customIcon,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            SizedBox(
              width: iconWidth,
              height: iconHeight,
              child:
                  customIcon ??
                  (isSvgIcon
                      ? SvgPicture.asset(
                          iconAssetPath,
                          width: iconWidth,
                          height: iconHeight,
                          colorFilter: iconTintColor != null
                              ? ColorFilter.mode(
                                  iconTintColor!,
                                  BlendMode.srcIn,
                                )
                              : null,
                        )
                      : Image.asset(
                          iconAssetPath,
                          width: iconWidth,
                          height: iconHeight,
                        )),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textColor,
                letterSpacing: -0.025 * 18,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

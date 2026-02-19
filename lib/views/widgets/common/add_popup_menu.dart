import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

/// 팝업 메뉴 항목 데이터
class AddMenuItem {
  final String label;
  final String svgPath;

  const AddMenuItem({required this.label, required this.svgPath});
}

/// + 버튼 팝업 메뉴에 표시할 항목 목록
const List<AddMenuItem> addMenuItems = [
  AddMenuItem(label: '링크', svgPath: AppAssets.linkIcon),
  AddMenuItem(label: '노트', svgPath: AppAssets.noteIcon),
  AddMenuItem(label: '파일', svgPath: AppAssets.fileIcon),
  AddMenuItem(label: '이미지', svgPath: AppAssets.imageIcon),
  AddMenuItem(label: '일정', svgPath: AppAssets.scheduleIcon),
];

/// + 버튼 위에 표시되는 팝업 메뉴
///
/// [anchorKey]로 + 버튼 위치를 받아 그 위에 팝업을 배치.
Future<int?> showAddPopupMenu(
  BuildContext context, {
  required GlobalKey anchorKey,
}) {
  final renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return Future.value(null);

  final buttonPos = renderBox.localToGlobal(Offset.zero);
  final buttonSize = renderBox.size;

  const menuWidth = 140.0;
  const itemHeight = 48.0;
  final menuHeight = itemHeight * addMenuItems.length;

  final left = buttonPos.dx + buttonSize.width - menuWidth;
  final top = buttonPos.dy - menuHeight - 12;

  return showGeneralDialog<int>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'AddPopupMenu',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          alignment: Alignment.bottomRight,
          child: child,
        ),
      );
    },
    pageBuilder: (context, _, __) {
      return Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: _AddPopupMenuContent(
                onItemTap: (index) {
                  Navigator.of(context).pop(index);
                },
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// 팝업 메뉴 본체 UI
class _AddPopupMenuContent extends StatelessWidget {
  final ValueChanged<int> onItemTap;

  const _AddPopupMenuContent({required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000D43).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(addMenuItems.length, (index) {
            final item = addMenuItems[index];
            return _PopupMenuItem(
              item: item,
              isLast: index == addMenuItems.length - 1,
              onTap: () => onItemTap(index),
            );
          }),
        ),
      ),
    );
  }
}

/// 팝업 메뉴 개별 항목
class _PopupMenuItem extends StatelessWidget {
  final AddMenuItem item;
  final bool isLast;
  final VoidCallback onTap;

  const _PopupMenuItem({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Row(
          children: [
            SvgPicture.asset(
              item.svgPath,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.gray600,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 16,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

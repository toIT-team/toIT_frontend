import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/event_assets.dart';

/// 일정 카드 롱프레스 시 표시되는 컨텍스트 메뉴
///
/// 수정/삭제(및 선택적 공유)를 터치 위치 근처에 오버레이로 표시합니다.
///
/// [onShare]가 null이면 공유 행을 넣지 않습니다.
Future<void> showEventCardContextMenu({
  required BuildContext context,
  required Offset touchPosition,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  VoidCallback? onShare,
}) async {
  await Navigator.of(context).push(
    _EventCardContextMenuRoute(
      touchPosition: touchPosition,
      onEdit: onEdit,
      onDelete: onDelete,
      onShare: onShare,
    ),
  );
}

class _EventCardContextMenuRoute extends PopupRoute<void> {
  _EventCardContextMenuRoute({
    required this.touchPosition,
    required this.onEdit,
    required this.onDelete,
    this.onShare,
  });

  final Offset touchPosition;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onShare;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.2);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => '닫기';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _EventCardContextMenuOverlay(
      touchPosition: touchPosition,
      onEdit: onEdit,
      onDelete: onDelete,
      onShare: onShare,
      animation: animation,
    );
  }
}

class _EventCardContextMenuOverlay extends StatelessWidget {
  const _EventCardContextMenuOverlay({
    required this.touchPosition,
    required this.onEdit,
    required this.onDelete,
    required this.animation,
    this.onShare,
  });

  final Offset touchPosition;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onShare;
  final Animation<double> animation;

  /// 패널 가로 폭 (각 행도 동일)
  static const double _menuWidth = 140.0;

  /// 각 메뉴 행 높이 (3행일 때 전체 높이 144)
  static const double _itemHeight = 48.0;
  static const double _radius = 12.0;

  double _menuHeight(bool showShare) {
    final rows = showShare ? 3 : 2;
    return _itemHeight * rows;
  }

  @override
  Widget build(BuildContext context) {
    final showShare = onShare != null;
    final menuHeight = _menuHeight(showShare);

    final screenSize = MediaQuery.of(context).size;
    var menuLeft = touchPosition.dx - _menuWidth / 2;
    menuLeft = menuLeft.clamp(16.0, screenSize.width - _menuWidth - 16);

    var menuTop = touchPosition.dy - 8;
    if (menuTop < 100) {
      menuTop = touchPosition.dy + 24;
    } else {
      menuTop = touchPosition.dy - 8 - menuHeight;
    }
    menuTop = menuTop.clamp(16.0, screenSize.height - menuHeight - 16);

    final splashTheme = Theme.of(context).copyWith(
      splashColor: const Color(0xFFC5D4E8).withValues(alpha: 0.45),
      highlightColor: const Color(0xFFC5D4E8).withValues(alpha: 0.25),
    );

    return Stack(
      children: [
        Positioned(
          left: menuLeft,
          top: menuTop,
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -0.05),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: Material(
                color: Colors.transparent,
                child: Theme(
                  data: splashTheme,
                  child: Container(
                    width: _menuWidth,
                    height: menuHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_radius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_radius),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuItem(
                            context: context,
                            iconAsset: EventAssets.bottomBarUpdate,
                            label: '수정',
                            onTap: () {
                              Navigator.of(context).pop();
                              onEdit();
                            },
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(_radius),
                            ),
                          ),
                          _buildMenuItem(
                            context: context,
                            iconAsset: EventAssets.bottomBarDelete,
                            label: '삭제',
                            onTap: () {
                              Navigator.of(context).pop();
                              onDelete();
                            },
                            borderRadius: showShare
                                ? BorderRadius.zero
                                : const BorderRadius.vertical(
                                    bottom: Radius.circular(_radius),
                                  ),
                          ),
                          if (showShare)
                            _buildMenuItem(
                              context: context,
                              iconAsset: EventAssets.bottomBarShare,
                              label: '공유',
                              onTap: () {
                                Navigator.of(context).pop();
                                onShare!();
                              },
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(_radius),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
    required BorderRadius borderRadius,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: SizedBox(
          height: _itemHeight,
          width: _menuWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SvgPicture.asset(iconAsset, width: 20, height: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

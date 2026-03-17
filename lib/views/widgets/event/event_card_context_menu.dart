import 'package:flutter/material.dart';

/// 일정 카드 롱프레스 시 표시되는 컨텍스트 메뉴
///
/// 수정/삭제 옵션을 터치 위치 근처에 오버레이로 표시
Future<void> showEventCardContextMenu({
  required BuildContext context,
  required Offset touchPosition,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) async {
  await Navigator.of(context).push(
    _EventCardContextMenuRoute(
      touchPosition: touchPosition,
      onEdit: onEdit,
      onDelete: onDelete,
    ),
  );
}

class _EventCardContextMenuRoute extends PopupRoute<void> {
  _EventCardContextMenuRoute({
    required this.touchPosition,
    required this.onEdit,
    required this.onDelete,
  });

  final Offset touchPosition;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
  });

  final Offset touchPosition;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Animation<double> animation;

  static const double _menuWidth = 140.0;
  static const double _itemHeight = 48.0;
  static const double _padding = 8.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var menuLeft = touchPosition.dx - _menuWidth / 2;
    menuLeft = menuLeft.clamp(16.0, screenSize.width - _menuWidth - 16);

    var menuTop = touchPosition.dy - 8;
    if (menuTop < 100) {
      menuTop = touchPosition.dy + 24;
    } else {
      menuTop = touchPosition.dy - 8 - (_itemHeight * 2 + _padding * 2);
    }
    menuTop = menuTop.clamp(16.0, screenSize.height - 120);

    return Stack(
      children: [
        Positioned(
          left: menuLeft,
          top: menuTop,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: _menuWidth,
                  padding: const EdgeInsets.symmetric(vertical: _padding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        context: context,
                        label: '수정',
                        icon: Icons.edit_outlined,
                        onTap: () {
                          Navigator.of(context).pop();
                          onEdit();
                        },
                      ),
                      _buildMenuItem(
                        context: context,
                        label: '삭제',
                        icon: Icons.delete_outline,
                        onTap: () {
                          Navigator.of(context).pop();
                          onDelete();
                        },
                      ),
                    ],
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
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: _itemHeight,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

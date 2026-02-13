import 'package:flutter/material.dart';

/// 컨텍스트 메뉴 아이템 데이터
class ContextMenuItem {
  const ContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// + 버튼의 컨텍스트 메뉴를 표시하는 함수
///
/// [anchorKey]를 기반으로 + 버튼 위에 팝업 메뉴를 표시함.
/// 배경 오버레이를 통해 바깥 터치 시 닫히게 해둠.
Future<void> showAddContextMenu({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<ContextMenuItem> items,
}) async {
  final renderBox =
      anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final anchorPosition = renderBox.localToGlobal(Offset.zero);
  final anchorSize = renderBox.size;

  await Navigator.of(context).push(
    _ContextMenuRoute(
      anchorPosition: anchorPosition,
      anchorSize: anchorSize,
      items: items,
    ),
  );
}

/// 컨텍스트 메뉴 라우트 (오버레이 방식)
class _ContextMenuRoute extends PopupRoute<void> {
  _ContextMenuRoute({
    required this.anchorPosition,
    required this.anchorSize,
    required this.items,
  });

  final Offset anchorPosition;
  final Size anchorSize;
  final List<ContextMenuItem> items;

  @override
  Color? get barrierColor =>
      Colors.black.withValues(alpha: 0.3);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => '닫기';

  @override
  Duration get transitionDuration =>
      const Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _ContextMenuOverlay(
      anchorPosition: anchorPosition,
      anchorSize: anchorSize,
      items: items,
      animation: animation,
    );
  }
}

/// 컨텍스트 메뉴 오버레이 위젯
class _ContextMenuOverlay extends StatelessWidget {
  const _ContextMenuOverlay({
    required this.anchorPosition,
    required this.anchorSize,
    required this.items,
    required this.animation,
  });

  final Offset anchorPosition;
  final Size anchorSize;
  final List<ContextMenuItem> items;
  final Animation<double> animation;

  static const double _menuWidth = 160;
  static const double _itemHeight = 48;
  static const double _menuPadding = 8;
  static const double _menuGap = 12;

  @override
  Widget build(BuildContext context) {
    final menuHeight =
        _itemHeight * items.length + _menuPadding * 2;

    // 메뉴를 + 버튼 위에, 오른쪽 정렬로 배치
    final menuLeft = anchorPosition.dx +
        anchorSize.width -
        _menuWidth;
    final menuTop =
        anchorPosition.dy - menuHeight - _menuGap;

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
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: _menuWidth,
                  padding: const EdgeInsets.symmetric(
                    vertical: _menuPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items
                        .map(_buildMenuItem)
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(ContextMenuItem item) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () {
            Navigator.of(context).pop();
            item.onTap();
          },
          child: SizedBox(
            height: _itemHeight,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/event_color_tokens.dart';

/// 색상 버튼 앵커 기준 컨텍스트 메뉴 표시
///
/// 바텀시트가 아닌, 앵커 위젯 바로 아래에 색상 팔레트를 오버레이로 표시
Future<void> showColorContextMenu({
  required BuildContext context,
  required GlobalKey anchorKey,
  required EventColorToken selectedToken,
  required ValueChanged<EventColorToken> onSelected,
}) async {
  final renderBox =
      anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final anchorPosition = renderBox.localToGlobal(Offset.zero);
  final anchorSize = renderBox.size;

  await Navigator.of(context).push(
    _ColorContextMenuRoute(
      anchorPosition: anchorPosition,
      anchorSize: anchorSize,
      selectedToken: selectedToken,
      onSelected: onSelected,
    ),
  );
}

class _ColorContextMenuRoute extends PopupRoute<void> {
  _ColorContextMenuRoute({
    required this.anchorPosition,
    required this.anchorSize,
    required this.selectedToken,
    required this.onSelected,
  });

  final Offset anchorPosition;
  final Size anchorSize;
  final EventColorToken selectedToken;
  final ValueChanged<EventColorToken> onSelected;

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
    return _ColorContextMenuOverlay(
      anchorPosition: anchorPosition,
      anchorSize: anchorSize,
      selectedToken: selectedToken,
      onSelected: onSelected,
      animation: animation,
    );
  }
}

class _ColorContextMenuOverlay extends StatelessWidget {
  const _ColorContextMenuOverlay({
    required this.anchorPosition,
    required this.anchorSize,
    required this.selectedToken,
    required this.onSelected,
    required this.animation,
  });

  final Offset anchorPosition;
  final Size anchorSize;
  final EventColorToken selectedToken;
  final ValueChanged<EventColorToken> onSelected;
  final Animation<double> animation;

  static const double _swatchSize = 36.0;
  static const double _spacing = 12.0;
  static const int _columns = 5;
  static const double _padding = 16.0;

  @override
  Widget build(BuildContext context) {
    final entries = EventColorTokens.pickerEntries;
    final menuWidth =
        _columns * _swatchSize + (_columns - 1) * _spacing + _padding * 2;

    final screenWidth = MediaQuery.of(context).size.width;
    var menuLeft = anchorPosition.dx + anchorSize.width / 2 - menuWidth / 2;
    menuLeft = menuLeft.clamp(16.0, screenWidth - menuWidth - 16);
    final menuTop = anchorPosition.dy + anchorSize.height + 8;

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
                  width: menuWidth,
                  padding: const EdgeInsets.all(_padding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: _spacing,
                    runSpacing: _spacing,
                    children: entries.map((e) {
                      final isSelected = e.token == selectedToken;
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelected(e.token);
                        },
                        child: Container(
                          width: _swatchSize,
                          height: _swatchSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: e.color,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

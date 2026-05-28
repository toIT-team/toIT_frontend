import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 하단 바 버튼 (아이콘 + 라벨)
///
/// [icon] 또는 [iconAsset] 중 하나는 반드시 지정해야 합니다.
class BottomBarButton extends StatefulWidget {
  const BottomBarButton({
    super.key,
    this.icon,
    this.iconAsset,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  }) : assert(
          (icon != null && iconAsset == null) ||
              (icon == null && iconAsset != null),
        );

  final IconData? icon;
  final String? iconAsset;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  @override
  State<BottomBarButton> createState() => _BottomBarButtonState();
}

class _BottomBarButtonState extends State<BottomBarButton> {
  bool _pressed = false;

  static const double _iconSize = 24;
  static const Duration _pressDuration = Duration(milliseconds: 120);
  static const double _pressedScale = 0.92;

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? Colors.grey.shade700;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: AnimatedScale(
          scale: _pressed ? _pressedScale : 1.0,
          duration: _pressDuration,
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(color),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.labelColor ?? color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (widget.iconAsset != null) {
      final path = widget.iconAsset!;
      if (path.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          path,
          width: _iconSize,
          height: _iconSize,
          fit: BoxFit.contain,
        );
      }
      return Image.asset(
        path,
        width: _iconSize,
        height: _iconSize,
        fit: BoxFit.contain,
      );
    }
    return Icon(
      widget.icon!,
      size: _iconSize,
      color: color,
    );
  }
}

import 'package:flutter/material.dart';

/// 탭 가능한 행 (오른쪽 화살표 포함)
class TappableRow extends StatelessWidget {
  const TappableRow({
    super.key,
    required this.title,
    this.titleColor,
    this.onTap,
    this.showArrow = true,
  });

  final String title;
  final Color? titleColor;
  final VoidCallback? onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: titleColor ?? Colors.black,
              ),
            ),
          ),
          if (showArrow)
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
        ],
      ),
    );
  }
}

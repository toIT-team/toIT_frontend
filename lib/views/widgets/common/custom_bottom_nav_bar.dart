import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'add_popup_menu.dart';

/// 커스텀 하단 네비게이션 바
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ValueChanged<int>? onAddMenuTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onAddMenuTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  final _addButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007CC9).withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.08),
                    blurRadius: 15,
                    spreadRadius: -5,
                    offset: const Offset(-5, -5),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.08),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: const Offset(5, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: _HomeIcon(isSelected: widget.currentIndex == 0),
                    isSelected: widget.currentIndex == 0,
                    onTap: () => widget.onTap(0),
                  ),
                  _NavItem(
                    icon: _CalendarIcon(isSelected: widget.currentIndex == 1),
                    isSelected: widget.currentIndex == 1,
                    onTap: () => widget.onTap(1),
                  ),
                  _NavItem(
                    icon: _ChatIcon(isSelected: widget.currentIndex == 2),
                    isSelected: widget.currentIndex == 2,
                    onTap: () => widget.onTap(2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          _AddButton(
            key: _addButtonKey,
            onTap: () async {
              final selected = await showAddPopupMenu(
                context,
                anchorKey: _addButtonKey,
              );
              if (selected != null) {
                widget.onAddMenuTap?.call(selected);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// 네비게이션 아이템
class _NavItem extends StatelessWidget {
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 60, height: 52, child: Center(child: icon)),
    );
  }
}

/// 추가 버튼
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.blue500,
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007CC9).withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

/// 홈 아이콘
class _HomeIcon extends StatelessWidget {
  final bool isSelected;

  const _HomeIcon({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.blue500 : AppColors.gray600;
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(painter: _HomeIconPainter(color: color)),
    );
  }
}

class _HomeIconPainter extends CustomPainter {
  final Color color;

  _HomeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // 지붕
    path.moveTo(size.width * 0.125, size.height * 0.417);
    path.lineTo(size.width * 0.5, size.height * 0.083);
    path.lineTo(size.width * 0.875, size.height * 0.417);

    // 집 본체
    path.moveTo(size.width * 0.208, size.height * 0.333);
    path.lineTo(size.width * 0.208, size.height * 0.875);
    path.lineTo(size.width * 0.792, size.height * 0.875);
    path.lineTo(size.width * 0.792, size.height * 0.333);

    // 문
    path.moveTo(size.width * 0.375, size.height * 0.875);
    path.lineTo(size.width * 0.375, size.height * 0.583);
    path.lineTo(size.width * 0.625, size.height * 0.583);
    path.lineTo(size.width * 0.625, size.height * 0.875);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HomeIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// 캘린더 아이콘
class _CalendarIcon extends StatelessWidget {
  final bool isSelected;

  const _CalendarIcon({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.blue500 : AppColors.gray600;
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(painter: _CalendarIconPainter(color: color)),
    );
  }
}

class _CalendarIconPainter extends CustomPainter {
  final Color color;

  _CalendarIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 캘린더 본체
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.125,
        size.height * 0.167,
        size.width * 0.75,
        size.height * 0.75,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    // 상단 고리들
    canvas.drawLine(
      Offset(size.width * 0.333, size.height * 0.083),
      Offset(size.width * 0.333, size.height * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.667, size.height * 0.083),
      Offset(size.width * 0.667, size.height * 0.25),
      paint,
    );

    // 가로선
    canvas.drawLine(
      Offset(size.width * 0.125, size.height * 0.417),
      Offset(size.width * 0.875, size.height * 0.417),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CalendarIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// 채팅 아이콘
class _ChatIcon extends StatelessWidget {
  final bool isSelected;

  const _ChatIcon({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.blue500 : AppColors.gray600;
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(painter: _ChatIconPainter(color: color)),
    );
  }
}

class _ChatIconPainter extends CustomPainter {
  final Color color;

  _ChatIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 말풍선 본체
    final path = Path();
    path.moveTo(size.width * 0.125, size.height * 0.167);
    path.lineTo(size.width * 0.875, size.height * 0.167);
    path.quadraticBezierTo(
      size.width * 0.917,
      size.height * 0.167,
      size.width * 0.917,
      size.height * 0.25,
    );
    path.lineTo(size.width * 0.917, size.height * 0.583);
    path.quadraticBezierTo(
      size.width * 0.917,
      size.height * 0.667,
      size.width * 0.833,
      size.height * 0.667,
    );
    path.lineTo(size.width * 0.333, size.height * 0.667);
    path.lineTo(size.width * 0.167, size.height * 0.833);
    path.lineTo(size.width * 0.167, size.height * 0.667);
    path.lineTo(size.width * 0.167, size.height * 0.667);
    path.quadraticBezierTo(
      size.width * 0.083,
      size.height * 0.667,
      size.width * 0.083,
      size.height * 0.583,
    );
    path.lineTo(size.width * 0.083, size.height * 0.25);
    path.quadraticBezierTo(
      size.width * 0.083,
      size.height * 0.167,
      size.width * 0.167,
      size.height * 0.167,
    );
    path.close();

    canvas.drawPath(path, paint);

    // 점 3개
    final dotRadius = size.width * 0.05;
    canvas.drawCircle(
      Offset(size.width * 0.333, size.height * 0.417),
      dotRadius,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.417),
      dotRadius,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.667, size.height * 0.417),
      dotRadius,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChatIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

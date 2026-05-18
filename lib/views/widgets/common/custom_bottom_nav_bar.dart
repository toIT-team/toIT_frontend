import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
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
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final mq = MediaQuery.of(context);
    // 갤럭시 제스처 내비 등: padding.bottom은 0인데 viewPadding만 있는 경우
    final systemBottom = math.max(
      math.max(mq.viewPadding.bottom, mq.padding.bottom),
      mq.systemGestureInsets.bottom,
    );
    // 시스템 내비 영역 위로 내부 네비를 항상 조금 띄운다.
    final navGap = isAndroid ? 12.0 : 8.0;
    final bottomMin = systemBottom + navGap;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: bottomMin),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Row(
          children: [
            // FAB(52) + 간격(16)을 뺀 나머지를 Expanded로 고정 → 합이 Row를 넘지 않음
            // (플립 등 제약·가시영역 불일치로 LayoutBuilder만 쓸 때 생기던 오버 방지)
            Expanded(
              child: LayoutBuilder(
                builder: (context, inner) {
                  const maxDesign = 259.0;
                  const innerMinW = 240.0;
                  final pillW = math.min(maxDesign, inner.maxWidth);
                  final navRow = Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: _NavSvgIcon(
                          assetPath: AppAssets.navHomeIcon,
                          isSelected: widget.currentIndex == 0,
                        ),
                        isSelected: widget.currentIndex == 0,
                        onTap: () => widget.onTap(0),
                      ),
                      _NavItem(
                        icon: _NavSvgIcon(
                          assetPath: AppAssets.navCalendarIcon,
                          isSelected: widget.currentIndex == 1,
                        ),
                        isSelected: widget.currentIndex == 1,
                        onTap: () => widget.onTap(1),
                      ),
                    ],
                  );
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: _GlassNavPill(
                      width: pillW,
                      height: 52,
                      child: pillW < innerMinW
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: innerMinW,
                                height: 52,
                                child: navRow,
                              ),
                            )
                          : navRow,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
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
      ),
    );
  }
}

/// 글래스모피즘 알약 네비 컨테이너.
///
/// 사용자 설명을 기준으로 다음 6개 레이어를 쌓습니다.
/// 1. 외곽 soft drop-shadow                   → 떠 있는 느낌
/// 2. [BackdropFilter] sigma 10                → 뒤 콘텐츠 색이 은은히 비침
/// 3. 수직 그라디언트 (상단 투명 → 하단 불투명) → 상단 어두움 / 하단 밝음
/// 4. 우하단 코너에서 올라오는 radial shine    → "유리가 빛나는" 광택
/// 5. 상단 edge 어두운 radial                  → 상단 살짝 그림자
/// 6. 1px 반투명 흰 테두리                     → 유리 가장자리
class _GlassNavPill extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _GlassNavPill({
    required this.width,
    required this.height,
    required this.child,
  });

  static const double _radius = 99;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.14),
                          Colors.white.withOpacity(0.26),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GlassLightingPainter(borderRadius: _radius),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.38),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 비대칭 라이팅 페인터.
///
/// 가로로 긴 알약(259×52) 도형이라 RadialGradient는 한쪽에 뭉치는 문제가 있어
/// 모든 라이팅을 LinearGradient로 처리해 가로 방향으로 고르게 분포시킵니다.
/// - 상단 edge: 옅은 회색 음영 (위→아래 방향, 균일하게 깔림)
/// - 우측 전반: 흰색 광택 (좌→우 방향, 우측으로 갈수록 진해짐)
class _GlassLightingPainter extends CustomPainter {
  final double borderRadius;

  const _GlassLightingPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    canvas.save();
    canvas.clipRRect(rrect);

    final topShadow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF7E8698).withOpacity(0.04),
          const Color(0x007E8698),
        ],
        stops: const [0.0, 0.55],
      ).createShader(rect);
    canvas.drawRect(rect, topShadow);

    final rightShine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.30)],
        stops: const [0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, rightShine);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlassLightingPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius;
}

/// 네비게이션 아이템
class _NavItem extends StatefulWidget {
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool isPressed = false;

  void setPressedState(bool nextPressed) {
    if (isPressed == nextPressed) return;
    setState(() {
      isPressed = nextPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pulseColor = widget.isSelected ? AppColors.blue500 : Colors.white;

    return GestureDetector(
      onTapDown: (_) {
        setPressedState(true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => setPressedState(false),
      onTapCancel: () => setPressedState(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 52,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                width: isPressed ? 36 : 32,
                height: isPressed ? 36 : 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: pulseColor.withOpacity(isPressed ? 0.20 : 0.0),
                      blurRadius: isPressed ? 12 : 0,
                      spreadRadius: isPressed ? 1 : 0,
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                scale: isPressed ? 0.9 : 1.0,
                child: widget.icon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 추가 버튼
class _AddButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddButton({super.key, required this.onTap});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool isPressed = false;

  void setPressedState(bool nextPressed) {
    if (isPressed == nextPressed) return;
    setState(() {
      isPressed = nextPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setPressedState(true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => setPressedState(false),
      onTapCancel: () => setPressedState(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        scale: isPressed ? 0.92 : 1.0,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.blue500,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

/// 네비 SVG 아이콘
class _NavSvgIcon extends StatelessWidget {
  final String assetPath;
  final bool isSelected;

  const _NavSvgIcon({required this.assetPath, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.blue500 : AppColors.gray600;
    return SizedBox(
      width: 28,
      height: 28,
      child: SvgPicture.asset(
        assetPath,
        width: 28,
        height: 28,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}

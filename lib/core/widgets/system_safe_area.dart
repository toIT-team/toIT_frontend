import 'package:flutter/material.dart';

import '../utils/system_ui_insets.dart';

/// [MediaQuery.padding]만으로는 Android에서 하단이 0이 되는 경우가 있어,
/// [SafeArea]에 [maintainBottomViewPadding]을 켜 [viewPadding]의 하단
/// (시스템 내비)를 반영한다.
class SystemSafeArea extends StatelessWidget {
  const SystemSafeArea({
    super.key,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    required this.child,
  });

  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final EdgeInsets minimum;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safeMinimum = EdgeInsets.fromLTRB(
      minimum.left,
      minimum.top,
      minimum.right,
      0,
    );
    final bottomInset = bottom
        ? systemBottomBarPadding(context) + minimum.bottom
        : minimum.bottom;

    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: false,
      minimum: safeMinimum,
      maintainBottomViewPadding: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: child,
      ),
    );
  }
}

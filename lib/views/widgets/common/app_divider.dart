import 'package:flutter/material.dart';

/// 앱 전역에서 사용하는 구분선
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.indent = 20.0,
    this.endIndent = 20.0,
    this.color,
  });

  final double indent;
  final double endIndent;
  final Color? color;

  static const defaultColor = Color(0xFFECECEC);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: color ?? defaultColor,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

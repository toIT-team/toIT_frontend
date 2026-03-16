import 'package:flutter/material.dart';

/// 커스텀 토글 스위치 위젯
///
/// 이미지 디자인에 맞춘 둥근 토글 스위치.
/// ON: 파란색 배경 + 오른쪽 흰색 원
/// OFF: 회색 배경 + 왼쪽 흰색 원
class CustomToggle extends StatelessWidget {
  const CustomToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF5B9CF4),
    this.inactiveColor = const Color(0xFFD1D5DB),
    this.thumbColor = Colors.white,
    this.width = 52,
    this.height = 30,
    this.thumbPadding = 2,
  });

  /// 현재 토글 상태
  final bool value;

  /// 토글 상태 변경 콜백
  final ValueChanged<bool>? onChanged;

  /// ON 상태 배경색
  final Color activeColor;

  /// OFF 상태 배경색
  final Color inactiveColor;

  /// 원형 핸들 색상
  final Color thumbColor;

  /// 토글 전체 너비
  final double width;

  /// 토글 전체 높이
  final double height;

  /// 원형 핸들 패딩
  final double thumbPadding;

  @override
  Widget build(BuildContext context) {
    final thumbSize = height - (thumbPadding * 2);

    return GestureDetector(
      onTap: onChanged != null
          ? () => onChanged!(!value)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        padding: EdgeInsets.all(thumbPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: value ? activeColor : inactiveColor,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: thumbColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

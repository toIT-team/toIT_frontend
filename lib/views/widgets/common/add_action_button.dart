import 'package:flutter/material.dart';

/// 추가 액션 플로팅 버튼 (+)
///
/// 네비게이션 바 우측에 독립적으로 배치되며,
/// 탭 시 컨텍스트 메뉴를 표시한다.
class AddActionButton extends StatelessWidget {
  const AddActionButton({
    super.key,
    required this.onTap,
  });

  /// 버튼 클릭 콜백
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFF4285F4),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x334285F4),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

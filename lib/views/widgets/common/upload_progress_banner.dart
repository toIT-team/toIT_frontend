import 'package:flutter/material.dart';

/// 이미지 업로드 진행 중 상단에 표시하는 상태 배너.
///
/// 네비게이션 쉘(화면 최상단 오버레이)과 보관함 상세(앱바 아래)에서
/// 공통으로 사용한다. 두 곳의 중복 구현을 하나로 합친 위젯이다.
class UploadProgressBanner extends StatelessWidget {
  const UploadProgressBanner({super.key, this.safeAreaTop = false});

  /// 상단 시스템 영역(노치·상태바)만큼 여백을 줄지 여부.
  /// 화면 최상단 오버레이로 쓸 때 true로 둔다.
  final bool safeAreaTop;

  static const String _message = '이미지 저장 중입니다. 앱을 종료하지 말아주세요.';

  @override
  Widget build(BuildContext context) {
    const banner = _BannerBody();
    return Material(
      color: Colors.transparent,
      child: safeAreaTop
          ? const SafeArea(bottom: false, child: banner)
          : banner,
    );
  }
}

class _BannerBody extends StatelessWidget {
  const _BannerBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A).withValues(alpha: 0.88),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              UploadProgressBanner._message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

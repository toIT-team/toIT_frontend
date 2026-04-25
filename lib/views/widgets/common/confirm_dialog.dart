import 'package:flutter/material.dart';

import '../../../core/widgets/system_safe_area.dart';

/// 재사용 가능한 확인 다이얼로그
///
/// 사진 2 디자인: 흰색 배경, 둥근 모서리, 하단 중앙 배치
/// 반환값: 확인 시 true, 취소 시 false
///
/// [cancelColor]이 null이면 취소 버튼은 기본 파란색이다.
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String message,
  String cancelLabel = '취소',
  String confirmLabel = '삭제',
  Color? confirmColor,
  Color? cancelColor,
}) async {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.28),
    builder: (dialogContext) {
      final media = MediaQuery.of(dialogContext);
      return MediaQuery(
        data: media.copyWith(textScaler: const TextScaler.linear(1.0)),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SystemSafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF222222),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 28),
                          ),
                          child: Text(
                            cancelLabel,
                            style: TextStyle(
                              color:
                                  cancelColor ?? const Color(0xFF379BFB),
                              fontSize: 16,
                              height: 1.1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 28),
                          ),
                          child: Text(
                            confirmLabel,
                            style: TextStyle(
                              color: confirmColor ?? const Color(0xFFFB373E),
                              fontSize: 16,
                              height: 1.1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      );
    },
  );
}

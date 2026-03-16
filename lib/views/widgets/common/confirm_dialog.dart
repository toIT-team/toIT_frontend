import 'package:flutter/material.dart';

/// 재사용 가능한 확인 다이얼로그
///
/// 사진 2 디자인: 흰색 배경, 둥근 모서리, 하단 중앙 배치
/// 반환값: 확인 시 true, 취소 시 false
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String message,
  String cancelLabel = '취소',
  String confirmLabel = '삭제',
  Color? confirmColor,
}) async {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (dialogContext) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        child: Text(
                          cancelLabel,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(true),
                        child: Text(
                          confirmLabel,
                          style: TextStyle(
                            color: confirmColor ?? Colors.red,
                            fontSize: 16,
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
      );
    },
  );
}

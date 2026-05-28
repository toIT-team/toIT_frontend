import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/system_safe_area.dart';

/// 삭제 확인 다이얼로그 (공통, Figma 스타일)
/// [message] 문구 표시 후 취소/삭제 버튼. true 반환 시 삭제 진행
Future<bool> showDeleteDialog(
  BuildContext context, {
  required String message,
  String? warningMessage,
  String cancelLabel = '취소',
  String confirmLabel = '삭제',
  Color confirmColor = AppColors.red500,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: AppColors.gray900.withOpacity(0.2),
    pageBuilder: (context, _, __) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SystemSafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: _DeleteDialogContent(
            message: message,
            warningMessage: warningMessage,
            cancelLabel: cancelLabel,
            confirmLabel: confirmLabel,
            confirmColor: confirmColor,
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class _DeleteDialogContent extends StatelessWidget {
  final String message;
  final String? warningMessage;
  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;

  const _DeleteDialogContent({
    required this.message,
    this.warningMessage,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 335),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.neutral50),
            boxShadow: const [
              BoxShadow(
                color: AppColors.overlayDialog,
                blurRadius: 16,
                offset: Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                  letterSpacing: -0.025 * 18,
                  height: 1.4,
                ),
              ),
              if (warningMessage != null &&
                  warningMessage!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  warningMessage!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 16,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(
                          cancelLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blue500,
                            letterSpacing: -0.025 * 18,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(
                          confirmLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: confirmColor,
                            letterSpacing: -0.025 * 18,
                            height: 1.4,
                          ),
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
  }
}

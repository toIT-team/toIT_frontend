import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/system_safe_area.dart';

/// 단일 확인 버튼 알림 (다른 모달과 동일한 바텀 카드 스타일)
///
/// [title] 기본값은 `알림`.
Future<void> showAppAlertDialog(
  BuildContext context, {
  String title = '알림',
  required String message,
  String confirmLabel = '확인',
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: AppColors.gray900.withValues(alpha: 0.2),
    pageBuilder: (dialogContext, _, _) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SystemSafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 335),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.neutral50),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.overlayDialog,
                      blurRadius: 16,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                        letterSpacing: -0.025 * 18,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray600,
                        letterSpacing: -0.025 * 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(dialogContext).pop(),
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              height: 44,
                              child: Center(
                                child: Text(
                                  confirmLabel,
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

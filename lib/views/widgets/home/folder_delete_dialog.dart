import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 보관함 삭제 확인 다이얼로그
/// true 반환 시 삭제 진행
Future<bool> showFolderDeleteDialog(
  BuildContext context, {
  required String folderName,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: AppColors.gray900.withOpacity(0.2),
    pageBuilder: (context, _, __) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: _DeleteDialogContent(folderName: folderName),
        ),
      );
    },
  );
  return result ?? false;
}

class _DeleteDialogContent extends StatelessWidget {
  final String folderName;

  const _DeleteDialogContent({required this.folderName});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 335,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.neutral50),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000D43),
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
              '[$folderName]을 정말 삭제하시겠습니까?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 18,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: const Text(
                        '취소',
                        style: TextStyle(
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
                      child: const Text(
                        '삭제',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.red500,
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
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/system_safe_area.dart';

/// 파일 케밥(미트볼) 메뉴 선택 액션 (Figma: 파일 미트볼메뉴)
enum FileKebabAction { editInfo, moveFolder, share, delete }

/// 파일 항목 케밥 메뉴 바텀시트 - 정보 수정 / 보관함 이동 / 공유 / 삭제
void showFileKebabSheet(
  BuildContext context, {
  required ValueChanged<FileKebabAction> onAction,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _FileKebabSheet(
      onAction: (action) {
        Navigator.of(sheetContext).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) => onAction(action));
      },
    ),
  );
}

class _FileKebabSheet extends StatelessWidget {
  const _FileKebabSheet({required this.onAction});
  final ValueChanged<FileKebabAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.neutral50, width: 1),
          left: BorderSide(color: AppColors.neutral50, width: 1),
          right: BorderSide(color: AppColors.neutral50, width: 1),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSheet,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SystemSafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _buildHandle(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _KebabRow(
                      iconAssetPath: AppAssets.editInformationIcon,
                      label: '정보 수정',
                      textColor: AppColors.gray900,
                      onTap: () => onAction(FileKebabAction.editInfo),
                    ),
                    _KebabRow(
                      iconAssetPath: AppAssets.moveFolderIcon,
                      label: '보관함 이동',
                      textColor: AppColors.gray900,
                      onTap: () => onAction(FileKebabAction.moveFolder),
                    ),
                    _KebabRow(
                      iconAssetPath: AppAssets.shareIcon,
                      label: '공유',
                      textColor: AppColors.gray900,
                      onTap: () => onAction(FileKebabAction.share),
                    ),
                    _KebabRow(
                      iconAssetPath: AppAssets.bottomSheetDeleteIcon,
                      label: '삭제',
                      textColor: AppColors.red500,
                      onTap: () => onAction(FileKebabAction.delete),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 42,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _KebabRow extends StatelessWidget {
  const _KebabRow({
    required this.iconAssetPath,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  final String iconAssetPath;
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              Image.asset(iconAssetPath, width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  letterSpacing: -0.025 * 18,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_assets.dart';
import 'add_folder_bottom_sheet.dart';
import 'folder_memo_bottom_sheet.dart';
import 'folder_delete_dialog.dart';
import 'folder_options_bottom_sheet.dart';
import '../../screens/folder_detail_screen.dart';

/// 폴더 타일 위젯
class FolderTile extends ConsumerWidget {
  final int foldersId;
  final String title;
  final String memo;
  final String countText;
  final Color accentColor;
  final int colorIndex;

  const FolderTile({
    super.key,
    this.foldersId = 0,
    required this.title,
    this.memo = '',
    required this.countText,
    required this.accentColor,
    this.colorIndex = 5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                FolderDetailScreen(foldersId: foldersId, folderName: title),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowCard,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final colorBoxBottom = height * 0.35; // 하단 35% 남기기
              final overlayTop = height * 0.25;
              final overlayBottom = height * 0.2;

              return Stack(
                children: [
                  // 상단 컬러 박스
                  Positioned(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: colorBoxBottom,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowAccent,
                            blurRadius: 8,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // 유리 느낌의 흰색 오버레이 (블러)
                  Positioned(
                    left: 8,
                    right: 8,
                    top: overlayTop,
                    bottom: overlayBottom,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(color: AppColors.overlayWhite90),
                      ),
                    ),
                  ),
                  // 폴더 아이콘
                  Positioned(
                    left: 14,
                    top: 12,
                    child: Image.asset(
                      AppAssets.folderIcon,
                      width: 22,
                      height: 22,
                    ),
                  ),
                  // 내용
                  Positioned(
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.25,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              countText,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.25,
                                height: 1.2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final option =
                                    await showFolderOptionsBottomSheet(context);
                                if (option == null || !context.mounted) {
                                  return;
                                }
                                switch (option) {
                                  case FolderOption.viewMemo:
                                    showFolderMemoBottomSheet(
                                      context,
                                      memo: memo,
                                    );
                                    break;
                                  case FolderOption.edit:
                                    final editResult =
                                        await showAddFolderBottomSheet(
                                          context,
                                          initialName: title,
                                          initialMemo: memo,
                                          initialColorIndex: colorIndex,
                                          isEditMode: true,
                                        );
                                    if (editResult != null) {
                                      final success = await ref
                                          .read(homeProvider.notifier)
                                          .updateFolder(
                                            foldersId: foldersId,
                                            name: editResult['name'] as String,
                                            memo: editResult['memo'] as String,
                                            colorIndex:
                                                editResult['colorIndex'] as int,
                                          );
                                      if (!success && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('보관함 수정에 실패했습니다.'),
                                          ),
                                        );
                                      }
                                    }
                                    break;
                                  case FolderOption.delete:
                                    final confirmed =
                                        await showFolderDeleteDialog(
                                          context,
                                          folderName: title,
                                        );
                                    if (!confirmed || !context.mounted) {
                                      break;
                                    }
                                    final deleted = await ref
                                        .read(homeProvider.notifier)
                                        .deleteFolder(foldersId: foldersId);
                                    if (!deleted && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('보관함 삭제에 실패했습니다.'),
                                        ),
                                      );
                                    }
                                    break;
                                }
                              },
                              child: Image.asset(
                                AppAssets.moreIcon,
                                width: 24,
                                height: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

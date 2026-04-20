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
/// [onTap]이 있으면 카드 탭 시 해당 콜백만 호출하고(보관함 이동 시트 등),
/// 없으면 상세 화면으로 이동 + 더보기 옵션 표시
class FolderTile extends ConsumerWidget {
  final int foldersId;
  final String title;
  final String memo;
  final String countText;
  final Color accentColor;
  final int colorIndex;
  final int iconIndex;
  final VoidCallback? onTap;

  const FolderTile({
    super.key,
    this.foldersId = 0,
    required this.title,
    this.memo = '',
    required this.countText,
    required this.accentColor,
    this.colorIndex = 5,
    this.iconIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap != null
          ? onTap
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FolderDetailScreen(
                    foldersId: foldersId,
                    folderName: title,
                  ),
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
                    left: 4,
                    top: 6,
                    child: _buildFolderIconImage(
                      'assets/icons/FolderIcon/${iconIndex.clamp(0, 11)}.png',
                      width: 44,
                      height: 44,
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
                            if (onTap != null)
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.primary,
                                size: 20,
                              )
                            else
                              GestureDetector(
                                onTap: () async {
                                  final option =
                                      await showFolderOptionsBottomSheet(
                                        context,
                                        isFavorite: ref
                                            .read(homeProvider.notifier)
                                            .isFavoriteFolder(foldersId),
                                      );
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
                                            initialIconIndex: iconIndex,
                                            isEditMode: true,
                                          );
                                      if (editResult != null) {
                                        final success = await ref
                                            .read(homeProvider.notifier)
                                            .updateFolder(
                                              foldersId: foldersId,
                                              name:
                                                  editResult['name'] as String,
                                              memo:
                                                  editResult['memo'] as String,
                                              colorIndex:
                                                  editResult['colorIndex']
                                                      as int,
                                              iconIndex:
                                                  editResult['iconIndex']
                                                      as int,
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
                                      final confirmed = await showDeleteDialog(
                                        context,
                                        message: '[$title]을 정말 삭제하시겠습니까?',
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
                                    case FolderOption.toggleFavorite:
                                      final nextFavoriteState = ref
                                          .read(homeProvider.notifier)
                                          .toggleFavoriteFolderLocal(foldersId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              nextFavoriteState
                                                  ? '즐겨찾기에 추가되었습니다.'
                                                  : '즐겨찾기가 해제되었습니다.',
                                            ),
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

  Widget _buildFolderIconImage(
    String imagePath, {
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, _, _) => Image.asset(
                AppAssets.folderIcon,
                width: width,
                height: height,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

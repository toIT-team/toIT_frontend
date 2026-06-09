import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/cloudfront_url_builder.dart';
import '../../core/widgets/cloudfront_image.dart';
import '../../models/dto/page_items_response_dto.dart';

/// 이미지 상세 화면
///
/// - 기본: 335x335 이미지 + 메모/날짜 영역
/// - 이미지 탭: 확장 모드(높이 696)로 전환
class ImageDetailScreen extends StatefulWidget {
  const ImageDetailScreen({super.key, required this.image, this.onMoreTap});

  final AttachmentImageDto image;
  final void Function(
    BuildContext context,
    AttachmentImageDto currentImage,
    ValueChanged<AttachmentImageDto> onUpdated,
  )? onMoreTap;

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  bool _isExpanded = false;
  late AttachmentImageDto _currentImage;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.image;
  }

  String _formatDateWithWeekday(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';
    final date = DateTime.tryParse(createdAt);
    if (date == null) return createdAt;
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayText = weekdays[date.weekday - 1];
    return '${date.year}.${date.month}.${date.day} ($weekdayText)';
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDateWithWeekday(_currentImage.createdAt);
    final memoText = _currentImage.textContent.trim().isEmpty
        ? '메모가 없습니다.'
        : _currentImage.textContent.trim();
    final memoLength = _currentImage.textContent.trim().length;
    final imageHeight = _isExpanded ? 696.0 : 335.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.gray900),
            onPressed: () {
              widget.onMoreTap?.call(
                context,
                _currentImage,
                (updatedImage) {
                  if (!mounted) return;
                  setState(() {
                    _currentImage = updatedImage;
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: SizedBox(
                  height: imageHeight,
                  child: _currentImage.objectKey.isNotEmpty
                      ? CloudFrontImage(
                          url: buildResizeImageUrl(
                            objectKey: _currentImage.objectKey,
                            displayWidth: 800,
                          ),
                          fit: BoxFit.cover,
                          loadingWidget: Container(
                            color: AppColors.neutral100,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: Container(color: AppColors.borderLight),
                        )
                      : Container(color: AppColors.borderLight),
                ),
              ),
            ),
            if (!_isExpanded) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: const [
                  Icon(
                    Icons.notes_outlined,
                    size: 20,
                    color: AppColors.blue500,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '메모',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                      letterSpacing: -0.025 * 18,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  memoText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                    letterSpacing: -0.025 * 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$memoLength/1000',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 16,
                    height: 1.25,
                  ),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

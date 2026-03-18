import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 검색 화면 상단 검색바
///
/// - 좌측 뒤로가기 아이콘
/// - 우측 둥근 검색 입력 필드 + 입력 시 우측 × 클리어 버튼
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.onBackPressed,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty ?? false;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 22,
                  color: AppColors.gray900,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '검색',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8E95A2),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        Icons.search,
                        size: 24,
                        color: AppColors.gray900,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 24,
                    ),
                    suffixIcon: hasText
                        ? GestureDetector(
                            onTap: () {
                              controller?.clear();
                              onChanged?.call('');
                            },
                            behavior: HitTestBehavior.opaque,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 14),
                              child: Icon(
                                Icons.cancel,
                                size: 20,
                                color: AppColors.gray600,
                              ),
                            ),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 24,
                    ),
                    contentPadding: const EdgeInsets.only(
                      top: 18,
                      bottom: 18,
                      right: 16,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                  ),
                  cursorColor: AppColors.gray900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'search_field_widget.dart';

/// 검색 화면 상단 검색바
///
/// - 좌측 뒤로가기 아이콘
/// - 우측 둥근 검색 입력 필드 + 입력 시 우측 DeleteIcon 클리어 버튼
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
              child: SearchFieldWidget(
                controller: controller,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

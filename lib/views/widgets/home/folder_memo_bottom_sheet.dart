import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 보관함 메모 보기 바텀시트
Future<void> showFolderMemoBottomSheet(
  BuildContext context, {
  required String memo,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.gray900.withOpacity(0.2),
    builder: (context) => _FolderMemoSheet(memo: memo),
  );
}

class _FolderMemoSheet extends StatelessWidget {
  final String memo;

  const _FolderMemoSheet({required this.memo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.neutral50)),
        boxShadow: [
          BoxShadow(
            color: Color(0x293F3F3F),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildDragHandle(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHeader(),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildMemoBox(),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCounter(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 42,
        height: 3,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.description_outlined, size: 20, color: AppColors.blue500),
        const SizedBox(width: 8),
        const Text(
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
    );
  }

  Widget _buildMemoBox() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(13),
      child: Text(
        memo.isEmpty ? '' : memo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.gray900,
          letterSpacing: -0.025 * 16,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCounter() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '${memo.length}/1000',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.gray600,
          letterSpacing: -0.025 * 16,
          height: 1.25,
        ),
      ),
    );
  }
}

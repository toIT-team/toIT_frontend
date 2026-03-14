import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 보관함 추가/수정 바텀시트 표시
Future<Map<String, dynamic>?> showAddFolderBottomSheet(
  BuildContext context, {
  String? initialName,
  String? initialMemo,
  int? initialColorIndex,
  bool isEditMode = false,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.gray900.withOpacity(0.2),
    builder: (context) => _AddFolderSheet(
      initialName: initialName,
      initialMemo: initialMemo,
      initialColorIndex: initialColorIndex,
      isEditMode: isEditMode,
    ),
  );
}

class _AddFolderSheet extends StatefulWidget {
  final String? initialName;
  final String? initialMemo;
  final int? initialColorIndex;
  final bool isEditMode;

  const _AddFolderSheet({
    this.initialName,
    this.initialMemo,
    this.initialColorIndex,
    this.isEditMode = false,
  });

  @override
  State<_AddFolderSheet> createState() => _AddFolderSheetState();
}

class _AddFolderSheetState extends State<_AddFolderSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _memoController;
  late int _selectedColorIndex;
  int _memoLength = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _memoController = TextEditingController(text: widget.initialMemo ?? '');
    _selectedColorIndex = widget.initialColorIndex ?? 5;
    _memoLength = _memoController.text.length;
    _memoController.addListener(() {
      setState(() => _memoLength = _memoController.text.length);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.of(context).pop({
      'name': name,
      'memo': _memoController.text.trim(),
      'colorIndex': _selectedColorIndex,
      'color': AppColors.folderColors[_selectedColorIndex],
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.neutral50)),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayScrim,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildDragHandle(),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 13),
              _buildNameInput(),
              const SizedBox(height: 20),
              _buildMemoSection(),
              const SizedBox(height: 20),
              _buildColorSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 상단 드래그 핸들
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

  /// 헤더: 제목 + "저장" 버튼
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.isEditMode ? '보관함 수정' : '새로운 보관함',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
            letterSpacing: -0.025 * 22,
            height: 1.5,
          ),
        ),
        GestureDetector(
          onTap: _onSave,
          child: const Text(
            '저장',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blue500,
              letterSpacing: -0.025 * 16,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 보관함 이름 입력 + 아이콘 버튼
  Widget _buildNameInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 16,
              ),
              decoration: const InputDecoration(
                hintText: '보관함 이름을 입력해주세요.',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                  letterSpacing: -0.025 * 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neutral50),
          ),
          child: Center(
            child: Container(
              width: 24,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.folderColors[_selectedColorIndex],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 메모(선택) 섹션
  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 20,
              color: AppColors.blue500,
            ),
            const SizedBox(width: 8),
            const Text(
              '메모(선택)',
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
        const SizedBox(height: 13),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(13),
          child: Stack(
            children: [
              TextField(
                controller: _memoController,
                maxLines: null,
                maxLength: 1000,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray900,
                  letterSpacing: -0.025 * 16,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: '보관함에 대한 정보를 간단하게\n메모해보세요.',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 16,
                    height: 1.4,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Text(
                  '$_memoLength/1000',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 16,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 색상 선택 섹션
  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette_outlined, size: 20, color: AppColors.blue500),
            const SizedBox(width: 8),
            const Text(
              '색상',
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
        const SizedBox(height: 13),
        _buildColorRow(0, 6),
        const SizedBox(height: 16),
        _buildColorRow(6, 10),
      ],
    );
  }

  /// 색상 원 한 줄
  Widget _buildColorRow(int start, int end) {
    return Row(
      children: [
        for (int i = start; i < end; i++) ...[
          if (i > start) const SizedBox(width: 24),
          GestureDetector(
            onTap: () => setState(() => _selectedColorIndex = i),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.folderColors[i],
                shape: BoxShape.circle,
                border: _selectedColorIndex == i
                    ? Border.all(color: AppColors.blue500, width: 2.5)
                    : null,
              ),
              child: _selectedColorIndex == i
                  ? const Center(
                      child: Icon(Icons.check, size: 18, color: Colors.white),
                    )
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

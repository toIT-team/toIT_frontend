import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 보관함 추가/수정 바텀시트 표시
Future<Map<String, dynamic>?> showAddFolderBottomSheet(
  BuildContext context, {
  String? initialName,
  String? initialMemo,
  int? initialColorIndex,
  int? initialIconIndex,
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
      initialIconIndex: initialIconIndex,
      isEditMode: isEditMode,
    ),
  );
}

class _AddFolderSheet extends StatefulWidget {
  final String? initialName;
  final String? initialMemo;
  final int? initialColorIndex;
  final int? initialIconIndex;
  final bool isEditMode;

  const _AddFolderSheet({
    this.initialName,
    this.initialMemo,
    this.initialColorIndex,
    this.initialIconIndex,
    this.isEditMode = false,
  });

  @override
  State<_AddFolderSheet> createState() => _AddFolderSheetState();
}

class _AddFolderSheetState extends State<_AddFolderSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _memoController;
  late int _selectedColorIndex;
  late int _selectedIconIndex;
  bool _isIconModalVisible = false;
  double _iconModalTop = 0;
  int _memoLength = 0;
  final GlobalKey _contentStackKey = GlobalKey();
  final GlobalKey _iconButtonKey = GlobalKey();
  final GlobalKey _memoInputBoxKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _memoController = TextEditingController(text: widget.initialMemo ?? '');
    _selectedColorIndex = widget.initialColorIndex ?? 5;
    _selectedIconIndex = widget.initialIconIndex ?? 0;
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
      'iconIndex': _selectedIconIndex,
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
          child: Stack(
            key: _contentStackKey,
            clipBehavior: Clip.none,
            children: [
              Column(
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
              if (_isIconModalVisible)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        _isIconModalVisible = false;
                      });
                    },
                  ),
                ),
              if (_isIconModalVisible)
                Positioned(
                  left: 0,
                  right: 0,
                  top: _iconModalTop,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _buildIconModal(),
                  ),
                ),
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
              onTap: () {
                if (_isIconModalVisible) {
                  setState(() {
                    _isIconModalVisible = false;
                  });
                }
              },
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
        GestureDetector(
          key: _iconButtonKey,
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_isIconModalVisible) {
              setState(() {
                _isIconModalVisible = false;
              });
              return;
            }
            _updateIconModalPosition();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isIconModalVisible
                    ? AppColors.blue500
                    : AppColors.neutral50,
              ),
            ),
            child: Center(
              child: _buildFolderIconImage(_selectedIconIndex, size: 44),
            ),
          ),
        ),
      ],
    );
  }

  void _updateIconModalPosition() {
    if (!mounted) return;
    final stackContext = _contentStackKey.currentContext;
    final iconContext = _iconButtonKey.currentContext;
    final memoContext = _memoInputBoxKey.currentContext;

    if (stackContext == null) {
      setState(() {
        _iconModalTop = 140;
        _isIconModalVisible = true;
      });
      return;
    }

    final stackBox = stackContext.findRenderObject() as RenderBox?;
    final iconBox = iconContext?.findRenderObject() as RenderBox?;
    final memoBox = memoContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) {
      setState(() {
        _iconModalTop = 140;
        _isIconModalVisible = true;
      });
      return;
    }

    double alignedTop = _iconModalTop;

    if (memoBox != null) {
      final stackGlobalOffset = stackBox.localToGlobal(Offset.zero);
      final memoGlobalOffset = memoBox.localToGlobal(Offset.zero);
      alignedTop = memoGlobalOffset.dy - stackGlobalOffset.dy;
    } else if (iconBox != null) {
      final iconOffset = iconBox.localToGlobal(Offset.zero, ancestor: stackBox);
      alignedTop = iconOffset.dy + iconBox.size.height + 12;
    } else {
      alignedTop = 140;
    }

    setState(() {
      _iconModalTop = alignedTop;
      _isIconModalVisible = true;
    });
  }

  Widget _buildIconModal() {
    return Container(
      width: 335,
      height: 153,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral50),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 13, 67, 0.06),
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '아이콘',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray600,
              letterSpacing: -0.025 * 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              itemCount: 12,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final isSelected = _selectedIconIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIconIndex = index;
                      _isIconModalVisible = false;
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.blue500)
                          : null,
                    ),
                    child: Center(
                      child: _buildFolderIconImage(index, size: 44),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _folderIconPath(int index) {
    final normalizedIndex = index.clamp(0, 11);
    return 'assets/icons/FolderIcon/$normalizedIndex.png';
  }

  Widget _buildFolderIconImage(int index, {required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.asset(
              _folderIconPath(index),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
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
          key: _memoInputBoxKey,
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

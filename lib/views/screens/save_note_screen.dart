import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

/// 노트 저장 화면 (퍼블리싱)
class SaveNoteScreen extends StatefulWidget {
  const SaveNoteScreen({super.key});

  @override
  State<SaveNoteScreen> createState() => _SaveNoteScreenState();
}

class _SaveNoteScreenState extends State<SaveNoteScreen> {
  final _noteController = TextEditingController();
  int _textLength = 0;

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() {
      setState(() => _textLength = _noteController.text.length);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onSave() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop({'textContent': text});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: _buildAppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildNoteSection(),
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral50),
            const SizedBox(height: 16),
            _buildFolderSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 44,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: AppColors.gray900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '노트 저장',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 22,
                height: 1.25,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _onSave,
              behavior: HitTestBehavior.opaque,
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
        ),
      ),
    );
  }

  /// 노트 입력 섹션
  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppAssets.noteIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.blue500,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '노트',
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
        const SizedBox(height: 10),
        Container(
          height: 210,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(13),
          child: TextField(
            controller: _noteController,
            maxLines: null,
            maxLength: 1000,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 16,
              height: 1.4,
            ),
            decoration: const InputDecoration(
              hintText: '내용을 입력해 주세요.',
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
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_textLength/1000',
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
    );
  }

  /// 보관함 추가 섹션
  Widget _buildFolderSection() {
    return GestureDetector(
      onTap: () {
        // TODO: 보관함 선택 화면 연결
        debugPrint('보관함 추가 탭');
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          const Icon(Icons.folder_outlined, size: 20, color: AppColors.blue500),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '보관함 추가',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 18,
                height: 1.4,
              ),
            ),
          ),
          const Icon(Icons.add, size: 20, color: AppColors.gray600),
        ],
      ),
    );
  }
}

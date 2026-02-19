import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

/// 이미지 저장 화면 (퍼블리싱)
class SaveImageScreen extends StatefulWidget {
  const SaveImageScreen({super.key});

  @override
  State<SaveImageScreen> createState() => _SaveImageScreenState();
}

class _SaveImageScreenState extends State<SaveImageScreen> {
  final _memoController = TextEditingController();
  int _memoLength = 0;
  bool _imageAttached = false;

  @override
  void initState() {
    super.initState();
    _memoController.addListener(() {
      setState(() => _memoLength = _memoController.text.length);
    });
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_imageAttached) return;
    Navigator.of(context).pop({'memo': _memoController.text.trim()});
  }

  void _onAttachImage() {
    // TODO: 이미지 선택 기능 연결
    debugPrint('사진 첨부 탭');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: _buildAppBar(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildImageSection(),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral50),
            const SizedBox(height: 16),
            _buildFolderSection(),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral50),
            const SizedBox(height: 20),
            _buildMemoSection(),
            const SizedBox(height: 24),
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
              '이미지 저장',
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

  /// 이미지 첨부 섹션
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppAssets.imageIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.blue500,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '이미지',
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
        GestureDetector(
          onTap: _onAttachImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_outlined, size: 24, color: AppColors.gray600),
                const SizedBox(height: 8),
                const Text(
                  '사진 첨부',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_imageAttached ? 1 : 0}/1',
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

  /// 메모(선택) 섹션
  Widget _buildMemoSection() {
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
        const SizedBox(height: 10),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(13),
          child: TextField(
            controller: _memoController,
            maxLines: null,
            maxLength: 1000,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 16,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText: '자료에 대한 정보를 간단하게 메모해보세요.',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
                letterSpacing: -0.025 * 16,
                height: 1.5,
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
    );
  }
}

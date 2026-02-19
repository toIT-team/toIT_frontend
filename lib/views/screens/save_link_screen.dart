import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

/// 링크 저장 화면 (퍼블리싱)
class SaveLinkScreen extends StatefulWidget {
  const SaveLinkScreen({super.key});

  @override
  State<SaveLinkScreen> createState() => _SaveLinkScreenState();
}

class _SaveLinkScreenState extends State<SaveLinkScreen> {
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _onSave() {
    final link = _linkController.text.trim();
    if (link.isEmpty) return;
    Navigator.of(context).pop({'link': link});
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
            _buildLinkSection(),
            const SizedBox(height: 16),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.neutral50,
            ),
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
              '링크 저장',
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

  /// 링크 입력 섹션
  Widget _buildLinkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppAssets.linkIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.blue500,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '링크',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 18,
                height: 1.25,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: TextField(
            controller: _linkController,
            keyboardType: TextInputType.url,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 16,
            ),
            decoration: const InputDecoration(
              hintText: '링크를 입력해 주세요.',
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
          const Icon(
            Icons.folder_outlined,
            size: 20,
            color: AppColors.blue500,
          ),
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
          const Icon(
            Icons.add,
            size: 20,
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }
}

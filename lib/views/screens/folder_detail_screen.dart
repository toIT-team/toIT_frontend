import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/dto/page_items_response_dto.dart';

/// 보관함 상세 화면 (링크 / 노트 / 파일 / 이미지 탭)
/// 퍼블리싱: API 연동 전
class FolderDetailScreen extends StatefulWidget {
  final int foldersId;
  final String folderName;

  const FolderDetailScreen({
    super.key,
    required this.foldersId,
    required this.folderName,
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.folderName,
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.025 * 22,
            height: 1.25,
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset(AppAssets.searchIcon, width: 24, height: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.gray900),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.gray900,
            unselectedLabelColor: AppColors.gray600,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.025 * 16,
              height: 1.4,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.025 * 16,
              height: 1.4,
            ),
            indicatorColor: AppColors.blue500,
            indicatorWeight: 2,
            dividerColor: AppColors.neutral50,
            tabs: const [
              Tab(text: '링크'),
              Tab(text: '노트'),
              Tab(text: '파일'),
              Tab(text: '이미지'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LinkTabContent(foldersId: widget.foldersId),
                _NoteTabContent(foldersId: widget.foldersId),
                _FileTabContent(foldersId: widget.foldersId),
                _ImageTabContent(foldersId: widget.foldersId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 상단 툴바: "전체 N개" / "최신순" 드롭다운
Widget _buildSectionToolbar(int count) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.sm,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '전체 ${count}개',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
            letterSpacing: -0.025 * 16,
            height: 1.5,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '최신순',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 16,
                height: 1.5,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Icon(Icons.keyboard_arrow_down, size: 24, color: AppColors.gray900),
          ],
        ),
      ],
    ),
  );
}

// ─── 링크 탭 (스웨거 links[] 필드명 사용) ───
class _LinkTabContent extends StatelessWidget {
  final int foldersId;

  const _LinkTabContent({required this.foldersId});

  /// 목업: API 연동 시 PageItemsResponseDto.links 로 교체
  static final List<LinkDto> _mockLinks = [
    LinkDto(
      linksId: 0,
      linksName: '디자이너가 알아야할 개발 지식',
      linksUrl: '',
      linksThumbnail: '',
      textContent:
          'PM (Product Manager) - 상품 전략을 세우고 관리하는 역할\n'
          'PD (Product Designer) - 사용자경험 설계 및 디지털 제품 비주얼 디자인',
      createdAt: '2026-01-02T12:00:00Z',
    ),
    LinkDto(
      linksId: 1,
      linksName: '디자이너가 알아야할 개발 지식 디자이너가 알아야할 개발 지식',
      linksUrl: '',
      linksThumbnail: '',
      textContent:
          'PM (Product Manager) - 상품 전략을 세우고 관리하는 역할\n'
          'PD (Product Designer) - 사용자경험 설계 및 디지털 제품 비주얼 디자인',
      createdAt: '2026-01-02T12:00:00Z',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionToolbar(_mockLinks.length),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _mockLinks.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.neutral50,
            ),
            itemBuilder: (context, index) {
              final link = _mockLinks[index];
              return _LinkItemRow(link: link, onMoreTap: () {});
            },
          ),
        ),
      ],
    );
  }
}

class _LinkItemRow extends StatelessWidget {
  final LinkDto link;
  final VoidCallback onMoreTap;

  const _LinkItemRow({required this.link, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    final dateText = _formatCreatedAt(link.createdAt);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      link.linksName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                        letterSpacing: -0.025 * 18,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      link.textContent,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray600,
                        letterSpacing: -0.025 * 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xxl),
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                  letterSpacing: -0.025 * 14,
                  height: 1.5,
                ),
              ),
              GestureDetector(
                onTap: onMoreTap,
                child: const Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatCreatedAt(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) return '';
  final date = DateTime.tryParse(createdAt);
  if (date == null) return createdAt;
  return '${date.year}.${date.month}.${date.day}';
}

// ─── 노트 탭 (스웨거 texts[]: List<String> 사용) ───
class _NoteTabContent extends StatelessWidget {
  final int foldersId;

  const _NoteTabContent({required this.foldersId});

  /// 목업: API 연동 시 PageItemsResponseDto.texts 로 교체
  static const List<String> _mockTexts = [
    '링크에 대한 정보를 간단하게 메모해보세요.',
    '링크에 대한 정보를 간단하게 메모해보세요.',
    '링크에 대한 정보를 간단하게 메모해보세요.',
    '링크에 대한 정보를 간단하게 메모해보세요. '
        '링크에 대한 정보를 간단하게 메모해보세요.',
    '링크에 대한 정보를 간단하게 메모해보세요.',
    '링크에 대한 정보를 간단하게 메모해보세요.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionToolbar(_mockTexts.length),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.md,
              children: _mockTexts
                  .map(
                    (text) =>
                        SizedBox(width: 104, child: _NoteCard(content: text)),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// 노트 카드 1개 (스웨거 texts[] 요소 = String)
class _NoteCard extends StatelessWidget {
  final String content;

  const _NoteCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final title = content.length > 20
        ? '${content.substring(0, 20)}...'
        : content.isEmpty
        ? '노트'
        : content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 104,
          height: 150,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.neutral50),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            content,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
              letterSpacing: -0.025 * 14,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
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
}

// ─── 파일 탭 (스웨거 files[] 필드명 사용) ───
class _FileTabContent extends StatelessWidget {
  final int foldersId;

  const _FileTabContent({required this.foldersId});

  /// 목업: API 연동 시 PageItemsResponseDto.files 로 교체
  static final List<AttachmentFileDto> _mockFiles = [
    AttachmentFileDto(
      attachmentsId: 0,
      usersId: 0,
      fileName: '20112323443.pdf',
      attachmentsSize: 27.6,
      createdAt: '2025-12-25T21:00:00Z',
    ),
    AttachmentFileDto(
      attachmentsId: 1,
      usersId: 0,
      fileName: '디자이너가 알아야할 개발.hwp',
      attachmentsSize: 27.6,
      createdAt: '2025-12-25T21:00:00Z',
    ),
    AttachmentFileDto(
      attachmentsId: 2,
      usersId: 0,
      fileName: '디자이너가 알아야할...발지식.hwp',
      attachmentsSize: 27.6,
      createdAt: '2025-12-25T21:00:00Z',
    ),
    AttachmentFileDto(
      attachmentsId: 3,
      usersId: 0,
      fileName: '디자이너가 알아야할 개발 지식',
      attachmentsSize: 27.6,
      createdAt: '2025-12-25T21:00:00Z',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionToolbar(_mockFiles.length),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _mockFiles.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.neutral50,
            ),
            itemBuilder: (context, index) {
              final file = _mockFiles[index];
              return _FileItemRow(file: file, onMoreTap: () {});
            },
          ),
        ),
      ],
    );
  }
}

class _FileItemRow extends StatelessWidget {
  final AttachmentFileDto file;
  final VoidCallback onMoreTap;

  const _FileItemRow({required this.file, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    final subtitle = _formatFileSubtitle(file.createdAt, file.attachmentsSize);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                    letterSpacing: -0.025 * 18,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMoreTap,
            child: const Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatFileSubtitle(String? createdAt, double attachmentsSize) {
  final dateStr = createdAt != null && createdAt.isNotEmpty
      ? _formatCreatedAt(createdAt)
      : '';
  final sizeStr = '${attachmentsSize.toStringAsFixed(1)}KB';
  return dateStr.isEmpty ? sizeStr : '$dateStr | $sizeStr';
}

// ─── 이미지 탭 (스웨거 images[] 필드명 사용) ───
class _ImageTabContent extends StatelessWidget {
  final int foldersId;

  const _ImageTabContent({required this.foldersId});

  /// 목업: API 연동 시 PageItemsResponseDto.images 로 교체
  static final List<AttachmentImageDto> _mockImages = [
    AttachmentImageDto(
      attachmentsId: 0,
      usersId: 0,
      fileName: 'image1.jpg',
      presignedUrl: '',
      imagesWidth: 161,
      imagesHeight: 163,
    ),
    AttachmentImageDto(
      attachmentsId: 1,
      usersId: 0,
      fileName: 'image2.jpg',
      presignedUrl: '',
      imagesWidth: 161,
      imagesHeight: 163,
    ),
    AttachmentImageDto(
      attachmentsId: 2,
      usersId: 0,
      fileName: 'image3.jpg',
      presignedUrl: '',
      imagesWidth: 161,
      imagesHeight: 163,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionToolbar(_mockImages.length),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm + 1,
              runSpacing: AppSpacing.md,
              children: _mockImages
                  .map(
                    (img) => Container(
                      width: 161,
                      height: 163,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

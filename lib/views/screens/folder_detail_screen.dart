import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/dto/page_items_response_dto.dart';
import '../../repositories/home_repository.dart';

/// 보관함 상세 화면 (링크 / 노트 / 파일 / 이미지 탭)
/// GET /page/items API 연동
class FolderDetailScreen extends ConsumerStatefulWidget {
  final int foldersId;
  final String folderName;

  const FolderDetailScreen({
    super.key,
    required this.foldersId,
    required this.folderName,
  });

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen>
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
    final pageItemsAsync = ref.watch(pageItemsProvider(widget.foldersId));

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
      body: pageItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '항목을 불러오지 못했습니다.',
                style: TextStyle(color: AppColors.gray600, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () =>
                    ref.invalidate(pageItemsProvider(widget.foldersId)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (data) => Column(
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
                  _LinkTabContent(links: data.links),
                  _NoteTabContent(texts: data.texts),
                  _FileTabContent(files: data.files),
                  _ImageTabContent(images: data.images),
                ],
              ),
            ),
          ],
        ),
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

// ─── 링크 탭 (API links[]) ───
class _LinkTabContent extends StatelessWidget {
  final List<LinkDto> links;

  const _LinkTabContent({required this.links});

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionToolbar(0),
          const Expanded(
            child: Center(
              child: Text(
                '저장된 링크가 없습니다.',
                style: TextStyle(fontSize: 16, color: AppColors.gray600),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionToolbar(links.length),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: links.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.neutral50,
            ),
            itemBuilder: (context, index) {
              final link = links[index];
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

// ─── 노트 탭 (API texts[] = 객체 배열) ───
class _NoteTabContent extends StatelessWidget {
  final List<TextDto> texts;

  const _NoteTabContent({required this.texts});

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionToolbar(0),
          const Expanded(
            child: Center(
              child: Text(
                '저장된 노트가 없습니다.',
                style: TextStyle(fontSize: 16, color: AppColors.gray600),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionToolbar(texts.length),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.md,
              children: texts
                  .map(
                    (text) => SizedBox(
                      width: 104,
                      child: _NoteCard(content: text.textContent),
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

/// 노트 카드 1개 (TextDto.textContent 표시)
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

// ─── 파일 탭 (API files[]) ───
class _FileTabContent extends StatelessWidget {
  final List<AttachmentFileDto> files;

  const _FileTabContent({required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionToolbar(0),
          const Expanded(
            child: Center(
              child: Text(
                '저장된 파일이 없습니다.',
                style: TextStyle(fontSize: 16, color: AppColors.gray600),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionToolbar(files.length),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: files.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.neutral50,
            ),
            itemBuilder: (context, index) {
              final file = files[index];
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

// ─── 이미지 탭 (API images[]) ───
class _ImageTabContent extends StatelessWidget {
  final List<AttachmentImageDto> images;

  const _ImageTabContent({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionToolbar(0),
          const Expanded(
            child: Center(
              child: Text(
                '저장된 이미지가 없습니다.',
                style: TextStyle(fontSize: 16, color: AppColors.gray600),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionToolbar(images.length),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm + 1,
              runSpacing: AppSpacing.md,
              children: images
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

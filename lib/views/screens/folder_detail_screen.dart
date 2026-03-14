import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/dto/page_items_response_dto.dart';
import '../../repositories/home_repository.dart';
import '../widgets/common/link_edit_sheet.dart';
import '../widgets/common/link_kebab_sheet.dart';
import '../widgets/common/note_kebab_sheet.dart';
import '../widgets/home/folder_delete_dialog.dart';
import 'note_detail_screen.dart';

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

  Future<void> _confirmAndDeleteLink(LinkDto link) async {
    final confirmed = await showDeleteDialog(context, message: '정말 삭제하시겠습니까?');
    if (confirmed != true || !mounted) return;

    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.deleteLink(
        foldersId: widget.foldersId,
        linksId: link.linksId,
      );
      ref.invalidate(pageItemsProvider(widget.foldersId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크가 삭제되었습니다.')));
    } on DioException catch (e) {
      if (!mounted) return;
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      String message = '삭제에 실패했습니다. 다시 시도해 주세요.';
      if (statusCode == 404 && data is Map && data['message'] != null) {
        message = data['message'] as String;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('삭제에 실패했습니다. 다시 시도해 주세요.')));
    }
  }

  void _showLinkKebabSheet(LinkDto link) {
    showLinkKebabSheet(
      context,
      link: link,
      onAction: (action) {
        switch (action) {
          case LinkKebabAction.editTitle:
            if (mounted) {
              showLinkEditSheet(
                context,
                link: link,
                foldersId: widget.foldersId,
                ref: ref,
              );
            }
            break;
          case LinkKebabAction.moveFolder:
            // TODO: 보관함 이동
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('보관함 이동 (준비 중)')));
            }
            break;
          case LinkKebabAction.share:
            // TODO: 공유
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('공유 (준비 중)')));
            }
            break;
          case LinkKebabAction.delete:
            if (mounted) _confirmAndDeleteLink(link);
            break;
        }
      },
    );
  }

  void _openNoteDetail(TextDto note) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            NoteDetailScreen(note: note, foldersId: widget.foldersId),
      ),
    );
  }

  void _showNoteKebabSheet(TextDto note) {
    showNoteKebabSheet(
      context,
      note: note,
      onAction: (action) {
        switch (action) {
          case NoteKebabAction.moveFolder:
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('보관함 이동 (준비 중)')));
            }
            break;
          case NoteKebabAction.delete:
            if (mounted) _confirmAndDeleteNote(note);
            break;
        }
      },
    );
  }

  Future<void> _confirmAndDeleteNote(TextDto note) async {
    final confirmed = await showDeleteDialog(context, message: '정말 삭제하시겠습니까?');
    if (confirmed != true || !mounted) return;
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.deleteText(
        foldersId: widget.foldersId,
        textsId: note.textsId,
      );
      ref.invalidate(pageItemsProvider(widget.foldersId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('노트가 삭제되었습니다.')));
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final message = data is Map && data['message'] != null
          ? data['message'] as String
          : '삭제에 실패했습니다. 다시 시도해 주세요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('삭제에 실패했습니다. 다시 시도해 주세요.')));
    }
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
                  _LinkTabContent(
                    links: data.links,
                    onLinkKebabTap: _showLinkKebabSheet,
                  ),
                  _NoteTabContent(
                    texts: data.texts,
                    onNoteTap: _openNoteDetail,
                    onNoteKebabTap: _showNoteKebabSheet,
                  ),
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
  final void Function(LinkDto link) onLinkKebabTap;

  const _LinkTabContent({required this.links, required this.onLinkKebabTap});

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
              return _LinkItemRow(
                link: link,
                onMoreTap: () => onLinkKebabTap(link),
              );
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
                    if (link.textContent.isNotEmpty)
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
              _LinkThumbnail(thumbnailUrl: link.linksThumbnail),
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
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AppColors.gray600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 링크 썸네일 (URL 있으면 네트워크 이미지, 없으면 플레이스홀더)
class _LinkThumbnail extends StatelessWidget {
  const _LinkThumbnail({required this.thumbnailUrl});

  static const double _size = 75;

  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final hasUrl = thumbnailUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        width: _size,
        height: _size,
        child: hasUrl
            ? Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.neutral100,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(width: _size, height: _size, color: AppColors.neutral100);
  }
}

String _formatCreatedAt(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) return '';
  final date = DateTime.tryParse(createdAt);
  if (date == null) return createdAt;
  return '${date.year}.${date.month}.${date.day}';
}

// ─── 노트 탭 (API texts[] = 객체 배열, 3열 그리드) ───
class _NoteTabContent extends StatelessWidget {
  final List<TextDto> texts;
  final void Function(TextDto note) onNoteTap;
  final void Function(TextDto note) onNoteKebabTap;

  const _NoteTabContent({
    required this.texts,
    required this.onNoteTap,
    required this.onNoteKebabTap,
  });

  static const double _cardWidth = 104;

  /// 제목(1줄) + 간격 + 날짜행 높이 여유 포함해 셀 높이 확보 (오버플로우 방지)
  static const double _cardTotalHeight = 214;
  static const double _gridSpacing = 12;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: _gridSpacing,
                crossAxisSpacing: _gridSpacing,
                childAspectRatio: _cardWidth / _cardTotalHeight,
              ),
              itemCount: texts.length,
              itemBuilder: (context, index) {
                final note = texts[index];
                return _NoteCard(
                  note: note,
                  onTap: () => onNoteTap(note),
                  onKebabTap: () => onNoteKebabTap(note),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 노트 카드 1개 (Figma: 104x150 내용 + 제목·날짜·케밥). 카드 탭 시 상세 화면 이동.
class _NoteCard extends StatelessWidget {
  final TextDto note;
  final VoidCallback onTap;
  final VoidCallback onKebabTap;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onKebabTap,
  });

  static const double _boxWidth = 104;
  static const double _boxHeight = 150;

  @override
  Widget build(BuildContext context) {
    final content = note.textContent;
    final title = content.length > 20
        ? '${content.substring(0, 20)}...'
        : content.isEmpty
        ? '노트'
        : content;
    final dateText = _formatCreatedAt(note.createdAt);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _boxWidth,
            height: _boxHeight,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.neutral50),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              content.isEmpty ? '링크에 대한 정보를 간단하게 메모해보세요.' : content,
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
          const SizedBox(height: 6),
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
          const SizedBox(height: 2),
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
                onTap: onKebabTap,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AppColors.gray600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

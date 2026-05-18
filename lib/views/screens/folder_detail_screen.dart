import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../models/pending_image_upload.dart';
import '../../providers/pending_uploads_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/folder_tab_index.dart';
import '../../models/dto/page_items_response_dto.dart';
import '../../models/home/folder_item.dart';
import '../../repositories/home_repository.dart';
import '../widgets/common/app_alert_dialog.dart';
import '../widgets/common/file_info_edit_sheet.dart';
import '../widgets/common/file_kebab_sheet.dart';
import '../widgets/common/link_edit_sheet.dart';
import '../widgets/common/link_kebab_sheet.dart';
import '../widgets/common/move_to_folder_sheet.dart';
import '../widgets/common/note_kebab_sheet.dart';
import '../widgets/common/add_popup_menu.dart';
import '../widgets/home/add_folder_bottom_sheet.dart';
import '../widgets/home/folder_delete_dialog.dart';
import '../widgets/home/folder_memo_bottom_sheet.dart';
import '../widgets/home/folder_options_bottom_sheet.dart';
import 'image_detail_screen.dart';
import 'note_detail_screen.dart';
import 'save_file_screen.dart';
import 'save_image_screen.dart';
import 'save_link_screen.dart';
import 'save_note_screen.dart';
import 'event_form_screen.dart';

/// 보관함 상세 화면 (링크 / 노트 / 파일 / 이미지 탭)
/// GET /page/items API 연동
class FolderDetailScreen extends ConsumerStatefulWidget {
  final int foldersId;
  final String folderName;

  /// 초기 탭 ([FolderTab.order] 기준)
  /// 탭 순서 변경 시 /core/constants/folder_tab_index.dart 의 order만 수정
  final FolderTab initialTab;

  const FolderDetailScreen({
    super.key,
    required this.foldersId,
    required this.folderName,
    this.initialTab = FolderTab.links,
  });

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen>
    with SingleTickerProviderStateMixin {
  static const String _filledFavoriteIconSvg = '''
<svg width="24" height="24" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M14.1667 2.5C14.6088 2.5 15.0327 2.67559 15.3453 2.98816C15.6578 3.30072 15.8334 3.72464 15.8334 4.16667V16.6667C15.8334 16.8126 15.795 16.956 15.7221 17.0824C15.6493 17.2089 15.5445 17.314 15.4183 17.3872C15.2921 17.4604 15.1488 17.4992 15.0029 17.4997C14.857 17.5002 14.7135 17.4624 14.5867 17.39L10.8267 15.2417C10.575 15.0978 10.29 15.0222 10.0001 15.0222C9.71013 15.0222 9.42519 15.0978 9.17342 15.2417L5.41341 17.39C5.2867 17.4624 5.1432 17.5002 4.99727 17.4997C4.85133 17.4992 4.70809 17.4604 4.58187 17.3872C4.45564 17.314 4.35086 17.2089 4.27801 17.0824C4.20516 16.956 4.1668 16.8126 4.16675 16.6667V4.16667C4.16675 3.72464 4.34234 3.30072 4.6549 2.98816C4.96746 2.67559 5.39139 2.5 5.83341 2.5H14.1667Z" fill="#222222" stroke="#222222" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  late TabController _tabController;
  String _folderName = '';
  final GlobalKey _addButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _folderName = widget.folderName;
    final tabCount = FolderTab.order.length;
    final initialIndex = FolderTab.indexOf(widget.initialTab);
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: initialIndex.clamp(0, tabCount - 1),
    );
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

  Future<void> _openFolderOptions() async {
    FolderItem? currentFolder;
    for (final folder in ref.read(homeProvider).folders) {
      if (folder.foldersId == widget.foldersId) {
        currentFolder = folder;
        break;
      }
    }
    final isDefaultFolder = currentFolder?.isDefault ?? false;
    final isFavoriteFolder = ref
        .read(homeProvider.notifier)
        .isFavoriteFolder(widget.foldersId);
    final option = await showFolderOptionsBottomSheet(
      context,
      isFavorite: isFavoriteFolder,
    );
    if (option == null || !mounted) return;

    final currentMemo = currentFolder?.memo ?? '';
    final currentColorIndex = currentFolder?.colorIndex ?? 5;
    final currentIconIndex = currentFolder?.iconIndex ?? 0;
    final currentTitle = currentFolder?.title ?? _folderName;

    switch (option) {
      case FolderOption.viewMemo:
        showFolderMemoBottomSheet(context, memo: currentMemo);
        break;
      case FolderOption.edit:
        final editResult = await showAddFolderBottomSheet(
          context,
          initialName: currentTitle,
          initialMemo: currentMemo,
          initialColorIndex: currentColorIndex,
          initialIconIndex: currentIconIndex,
          isEditMode: true,
        );
        if (editResult == null || !mounted) return;
        final success = await ref
            .read(homeProvider.notifier)
            .updateFolder(
              foldersId: widget.foldersId,
              name: editResult['name'] as String,
              memo: editResult['memo'] as String,
              colorIndex: editResult['colorIndex'] as int,
              iconIndex: editResult['iconIndex'] as int,
            );
        if (!mounted) return;
        if (!success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('보관함 수정에 실패했습니다.')));
          return;
        }
        setState(() {
          _folderName = editResult['name'] as String;
        });
        break;
      case FolderOption.delete:
        if (isDefaultFolder) {
          await showAppAlertDialog(context, message: '기본 보관함은 삭제할 수 없습니다.');
          return;
        }
        final confirmed = await showDeleteDialog(
          context,
          message: '[$_folderName]을 정말 삭제하시겠습니까?',
          warningMessage: '보관함을 삭제하면 포함된 모든 자료가 같이 삭제됩니다.',
        );
        if (!confirmed || !mounted) return;
        final deleted = await ref
            .read(homeProvider.notifier)
            .deleteFolder(foldersId: widget.foldersId);
        if (!mounted) return;
        if (!deleted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('보관함 삭제에 실패했습니다.')));
          return;
        }
        Navigator.of(context).pop();
        break;
      case FolderOption.toggleFavorite:
        final nextFavoriteState = await ref
            .read(homeProvider.notifier)
            .toggleFavoriteFolder(foldersId: widget.foldersId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nextFavoriteState == null
                  ? '즐겨찾기 변경에 실패했습니다.'
                  : nextFavoriteState
                  ? '즐겨찾기에 추가되었습니다.'
                  : '즐겨찾기가 해제되었습니다.',
            ),
          ),
        );
        break;
    }
  }

  Future<void> _toggleFavoriteFromHeader() async {
    final isNowFavorite = await ref
        .read(homeProvider.notifier)
        .toggleFavoriteFolder(foldersId: widget.foldersId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite == null
              ? '즐겨찾기 변경에 실패했습니다.'
              : isNowFavorite
              ? '즐겨찾기에 추가되었습니다.'
              : '즐겨찾기가 해제되었습니다.',
        ),
      ),
    );
  }

  Future<void> _onAddMenuTap() async {
    final selected = await showAddPopupMenu(context, anchorKey: _addButtonKey);
    if (!mounted || selected == null) return;

    switch (selected) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SaveLinkScreen(initialFolderId: widget.foldersId),
          ),
        );
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SaveNoteScreen(initialFolderId: widget.foldersId),
          ),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SaveFileScreen(initialFolderId: widget.foldersId),
          ),
        );
        break;
      case 3:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SaveImageScreen(initialFolderId: widget.foldersId),
          ),
        );
        break;
      case 4:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const EventFormScreen()));
        break;
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
            if (mounted) {
              showMoveToFolderSheet(
                context,
                ref,
                currentFoldersId: widget.foldersId,
                onSelect: (folder) => _moveLinkToFolder(link, folder.foldersId),
              );
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

  Future<void> _openLink(LinkDto link) async {
    final rawUrl = link.linksUrl.trim();
    if (rawUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('열 수 있는 링크가 없습니다.')));
      return;
    }

    Uri? uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('유효하지 않은 링크입니다.')));
      return;
    }

    if (uri.scheme.isEmpty) {
      uri = Uri.tryParse('https://$rawUrl');
      if (uri == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('유효하지 않은 링크입니다.')));
        return;
      }
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('링크를 열 수 없습니다.')));
  }

  void _openNoteDetail(TextDto note) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            NoteDetailScreen(note: note, foldersId: widget.foldersId),
      ),
    );
  }

  void _openImageDetail(AttachmentImageDto image) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ImageDetailScreen(
          image: image,
          onMoreTap: (detailContext, currentImage, onUpdated) =>
              _showImageKebabSheet(
                currentImage,
                contextOverride: detailContext,
                onImageUpdated: onUpdated,
              ),
        ),
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
              showMoveToFolderSheet(
                context,
                ref,
                currentFoldersId: widget.foldersId,
                onSelect: (folder) => _moveNoteToFolder(note, folder.foldersId),
              );
            }
            break;
          case NoteKebabAction.delete:
            if (mounted) _confirmAndDeleteNote(note);
            break;
        }
      },
    );
  }

  Future<void> _moveNoteToFolder(TextDto note, int moveFoldersId) async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.moveText(
        foldersId: widget.foldersId,
        moveFoldersId: moveFoldersId,
        textsId: note.textsId,
      );
      ref.invalidate(homeProvider);
      ref.invalidate(pageItemsProvider(widget.foldersId));
      ref.invalidate(pageItemsProvider(moveFoldersId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('노트가 이동되었습니다.')));
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final message = data is Map && data['message'] != null
          ? data['message'] as String
          : '이동에 실패했습니다. 다시 시도해 주세요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이동에 실패했습니다. 다시 시도해 주세요.')));
    }
  }

  Future<void> _moveLinkToFolder(LinkDto link, int moveFoldersId) async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.moveLink(
        foldersId: widget.foldersId,
        moveFoldersId: moveFoldersId,
        linksId: link.linksId,
      );
      ref.invalidate(homeProvider);
      ref.invalidate(pageItemsProvider(widget.foldersId));
      ref.invalidate(pageItemsProvider(moveFoldersId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크가 이동되었습니다.')));
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final message = data is Map && data['message'] != null
          ? data['message'] as String
          : '이동에 실패했습니다. 다시 시도해 주세요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이동에 실패했습니다. 다시 시도해 주세요.')));
    }
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

  void _showFileKebabSheet(AttachmentFileDto file) {
    showFileKebabSheet(
      context,
      onAction: (action) {
        final messenger = ScaffoldMessenger.of(context);
        switch (action) {
          case FileKebabAction.editInfo:
            showAttachmentInfoEditSheet(
              context,
              sheetTitle: '정보 수정',
              titleLabel: '파일 제목',
              descriptionLabel: '파일 설명',
              initialTitle: file.fileName,
              initialDescription: file.textContent,
            ).then((edited) async {
              if (edited == null) return;
              try {
                final repository = ref.read(homeRepositoryProvider);
                await repository.updateAttachmentFileName(
                  foldersId: widget.foldersId,
                  attachmentsId: file.attachmentsId,
                  textContent: edited.description,
                  fileName: edited.title,
                );
                ref.invalidate(pageItemsProvider(widget.foldersId));
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('파일 정보가 수정되었습니다.')),
                );
              } on DioException catch (e) {
                if (!mounted) return;
                final data = e.response?.data;
                final message = data is Map && data['message'] != null
                    ? data['message'] as String
                    : '수정에 실패했습니다. 다시 시도해 주세요.';
                messenger.showSnackBar(SnackBar(content: Text(message)));
              } catch (_) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('수정에 실패했습니다. 다시 시도해 주세요.')),
                );
              }
            });
            break;
          case FileKebabAction.moveFolder:
            showMoveToFolderSheet(
              context,
              ref,
              currentFoldersId: widget.foldersId,
              onSelect: (folder) =>
                  _moveAttachmentToFolder(file.attachmentsId, folder.foldersId),
            );
            break;
          case FileKebabAction.share:
            messenger.showSnackBar(
              const SnackBar(content: Text('공유 기능은 준비 중입니다.')),
            );
            break;
          case FileKebabAction.delete:
            _confirmAndDeleteAttachment(file.attachmentsId);
            break;
        }
      },
    );
  }

  void _showImageKebabSheet(
    AttachmentImageDto image, {
    BuildContext? contextOverride,
    ValueChanged<AttachmentImageDto>? onImageUpdated,
  }) {
    final baseContext = contextOverride ?? context;
    final shouldCloseDetailOnSuccess = contextOverride != null;
    showFileKebabSheet(
      baseContext,
      onAction: (action) {
        final messenger = ScaffoldMessenger.of(baseContext);
        switch (action) {
          case FileKebabAction.editInfo:
            showAttachmentInfoEditSheet(
              baseContext,
              sheetTitle: '정보 수정',
              titleLabel: '이미지 제목',
              descriptionLabel: '이미지 설명',
              initialTitle: image.fileName,
              initialDescription: image.textContent,
              showTitleField: false,
            ).then((edited) async {
              if (edited == null) return;
              try {
                final repository = ref.read(homeRepositoryProvider);
                await repository.updateAttachmentFileName(
                  foldersId: widget.foldersId,
                  attachmentsId: image.attachmentsId,
                  textContent: edited.description,
                  fileName: image.fileName,
                );
                ref.invalidate(pageItemsProvider(widget.foldersId));
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('이미지 정보가 수정되었습니다.')),
                );
                onImageUpdated?.call(
                  image.copyWith(textContent: edited.description),
                );
              } on DioException catch (e) {
                if (!mounted) return;
                final data = e.response?.data;
                final message = data is Map && data['message'] != null
                    ? data['message'] as String
                    : '수정에 실패했습니다. 다시 시도해 주세요.';
                messenger.showSnackBar(SnackBar(content: Text(message)));
              } catch (_) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('수정에 실패했습니다. 다시 시도해 주세요.')),
                );
              }
            });
            break;
          case FileKebabAction.moveFolder:
            showMoveToFolderSheet(
              baseContext,
              ref,
              currentFoldersId: widget.foldersId,
              onSelect: (folder) => _moveAttachmentToFolder(
                image.attachmentsId,
                folder.foldersId,
                detailContextToClose: shouldCloseDetailOnSuccess
                    ? contextOverride
                    : null,
              ),
            );
            break;
          case FileKebabAction.share:
            messenger.showSnackBar(
              const SnackBar(content: Text('공유 기능은 준비 중입니다.')),
            );
            break;
          case FileKebabAction.delete:
            _confirmAndDeleteAttachment(image.attachmentsId);
            break;
        }
      },
    );
  }

  Future<void> _moveAttachmentToFolder(
    int attachmentsId,
    int moveFoldersId, {
    BuildContext? detailContextToClose,
  }) async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.moveAttachment(
        foldersId: widget.foldersId,
        moveFoldersId: moveFoldersId,
        attachmentsId: attachmentsId,
      );
      ref.invalidate(homeProvider);
      ref.invalidate(pageItemsProvider(widget.foldersId));
      ref.invalidate(pageItemsProvider(moveFoldersId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('보관함 이동이 완료되었습니다.')));
      if (detailContextToClose != null &&
          Navigator.of(detailContextToClose).canPop()) {
        Navigator.of(detailContextToClose).pop();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final message = data is Map && data['message'] != null
          ? data['message'] as String
          : '이동에 실패했습니다. 다시 시도해 주세요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이동에 실패했습니다. 다시 시도해 주세요.')));
    }
  }

  Future<void> _confirmAndDeleteAttachment(int attachmentsId) async {
    final confirmed = await showDeleteDialog(context, message: '정말 삭제하시겠습니까?');
    if (confirmed != true || !mounted) return;

    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.deleteAttachment(attachmentsId: attachmentsId);
      ref.invalidate(homeProvider);
      ref.invalidate(pageItemsProvider(widget.foldersId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('삭제가 완료되었습니다.')));
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

  List<Widget> _buildTabViewChildren(PageItemsResponseDto data) {
    return FolderTab.order.map((tab) {
      switch (tab) {
        case FolderTab.links:
          return _LinkTabContent(
            links: data.links,
            onLinkTap: _openLink,
            onLinkKebabTap: _showLinkKebabSheet,
          );
        case FolderTab.notes:
          return _NoteTabContent(
            texts: data.texts,
            onNoteTap: _openNoteDetail,
            onNoteKebabTap: _showNoteKebabSheet,
          );
        case FolderTab.files:
          return _FileTabContent(
            files: data.files,
            onFileKebabTap: _showFileKebabSheet,
          );
        case FolderTab.images:
          final pending = ref
              .watch(pendingUploadsProvider)
              .where((u) => u.folderId == widget.foldersId)
              .toList();
          return _ImageTabContent(
            images: data.images,
            pendingUploads: pending,
            onImageLongPress: _showImageKebabSheet,
            onImageTap: _openImageDetail,
          );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 즐겨찾기 토글 시 AppBar 아이콘도 즉시 리빌드되도록 구독
    ref.watch(homeProvider.select((state) => state.folders));
    final isFavoriteFolder = ref
        .read(homeProvider.notifier)
        .isFavoriteFolder(widget.foldersId);
    final pageItemsAsync = ref.watch(pageItemsProvider(widget.foldersId));
    final isUploading = ref.watch(pendingUploadsProvider).any(
      (u) => u.status == PendingUploadStatus.uploading,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _TapScaleIconButton(
          onTap: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900),
        ),
        title: Text(
          _folderName,
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.025 * 22,
            height: 1.25,
          ),
        ),
        actions: [
          _TapScaleIconButton(
            onTap: () {},
            icon: Image.asset(AppAssets.searchIcon, width: 24, height: 24),
          ),
          _TapScaleIconButton(
            onTap: _toggleFavoriteFromHeader,
            icon: SizedBox(
              width: 24,
              height: 24,
              child: isFavoriteFolder
                  ? SvgPicture.string(
                      _filledFavoriteIconSvg,
                      width: 24,
                      height: 24,
                    )
                  : SvgPicture.asset(
                      AppAssets.favoriteIcon,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.gray900,
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ),
          _TapScaleIconButton(
            onTap: _openFolderOptions,
            icon: const Icon(Icons.more_horiz, color: AppColors.gray900),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isUploading)
            Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.88),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '이미지 저장 중입니다. 앱을 종료하지 말아주세요.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: pageItemsAsync.when(
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
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
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
              tabs: FolderTab.order.map((tab) => Tab(text: tab.label)).toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _buildTabViewChildren(data),
              ),
            ),
          ],
        ),
      ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 16),
        child: _TapScale(
          key: _addButtonKey,
          onTap: _onAddMenuTap,
          pressedScale: 0.94,
          borderRadius: BorderRadius.circular(99),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.blue500,
              borderRadius: BorderRadius.circular(99),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowNavBlue.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _TapScaleIconButton extends StatelessWidget {
  const _TapScaleIconButton({required this.onTap, required this.icon});

  final VoidCallback onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      pressedScale: 0.92,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(width: 44, height: 44, child: Center(child: icon)),
    );
  }
}

class _TapScale extends StatefulWidget {
  const _TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.98,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final BorderRadius? borderRadius;

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool isPressed = false;

  void setPressed(bool nextValue) {
    if (isPressed == nextValue) return;
    setState(() {
      isPressed = nextValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);
    return AnimatedScale(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      scale: isPressed ? widget.pressedScale : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onHighlightChanged: setPressed,
          borderRadius: radius,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isPressed
                  ? AppColors.neutral100.withOpacity(0.45)
                  : Colors.transparent,
              borderRadius: radius,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 상단 툴바: "전체 N개"
Widget _buildSectionToolbar(
  int count, {
  bool removeBottomPadding = false,
}) {
  return Padding(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.xs + 2,
      AppSpacing.lg,
      removeBottomPadding ? 0 : AppSpacing.xxs,
    ),
    child: Text(
      '전체 ${count}개',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.gray600,
        letterSpacing: -0.025 * 16,
        height: 1.5,
      ),
    ),
  );
}

// ─── 링크 탭 (API links[]) ───
class _LinkTabContent extends StatelessWidget {
  final List<LinkDto> links;
  final void Function(LinkDto link) onLinkTap;
  final void Function(LinkDto link) onLinkKebabTap;

  const _LinkTabContent({
    required this.links,
    required this.onLinkTap,
    required this.onLinkKebabTap,
  });

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionToolbar(0, removeBottomPadding: true),
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
        _buildSectionToolbar(links.length, removeBottomPadding: true),
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
                onTap: () => onLinkTap(link),
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
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _LinkItemRow({
    required this.link,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = _formatCreatedAt(link.createdAt);
    return _TapScale(
      onTap: onTap,
      pressedScale: 0.995,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
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
                _TapScale(
                  onTap: onMoreTap,
                  pressedScale: 0.92,
                  borderRadius: BorderRadius.circular(999),
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

  /// 제목(1줄) + 간격 + 날짜행 + 기기별 폰트 메트릭 여유
  static const double _cardTotalHeight = 230;
  static const double _gridSpacing = 12;

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionToolbar(0, removeBottomPadding: true),
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
                return LayoutBuilder(
                  builder: (context, cellConstraints) {
                    final cellW = cellConstraints.maxWidth;
                    final displayW = cellW < _cardWidth ? cellW : _cardWidth;
                    return _NoteCard(
                      note: note,
                      displayWidth: displayW,
                      onTap: () => onNoteTap(note),
                      onKebabTap: () => onNoteKebabTap(note),
                    );
                  },
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
  final double displayWidth;
  final VoidCallback onTap;
  final VoidCallback onKebabTap;

  const _NoteCard({
    required this.note,
    required this.displayWidth,
    required this.onTap,
    required this.onKebabTap,
  });

  static const double _designBoxWidth = 104;
  static const double _designBoxHeight = 150;

  @override
  Widget build(BuildContext context) {
    final boxW = displayWidth;
    final boxH = _designBoxHeight * (boxW / _designBoxWidth);
    final content = note.textContent;
    final title = content.length > 20
        ? '${content.substring(0, 20)}...'
        : content.isEmpty
        ? '노트'
        : content;
    final dateText = _formatCreatedAt(note.createdAt);

    return _TapScale(
      onTap: onTap,
      pressedScale: 0.99,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: boxW,
            height: boxH,
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
              Expanded(
                child: Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    letterSpacing: -0.025 * 14,
                    height: 1.5,
                  ),
                ),
              ),
              _TapScale(
                onTap: onKebabTap,
                pressedScale: 0.92,
                borderRadius: BorderRadius.circular(999),
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
  final void Function(AttachmentFileDto file) onFileKebabTap;

  const _FileTabContent({required this.files, required this.onFileKebabTap});

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
        _buildSectionToolbar(files.length, removeBottomPadding: true),
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
              return _FileItemRow(
                file: file,
                onMoreTap: () => onFileKebabTap(file),
              );
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
    final fileIconPath = _resolveFileIconAssetPath(
      fileName: file.fileName,
      attachmentsExtension: file.attachmentsExtension,
    );
    return _TapScale(
      onTap: () {},
      pressedScale: 0.995,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            _buildFileIconBox(fileIconPath),
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
            _TapScale(
              onTap: onMoreTap,
              pressedScale: 0.92,
              borderRadius: BorderRadius.circular(999),
              child: const Icon(
                Icons.more_horiz,
                size: 20,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIconBox(String? fileIconPath) {
    if (fileIconPath == null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Image.asset(
        fileIconPath,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
      ),
    );
  }
}

String? _resolveFileIconAssetPath({
  required String fileName,
  required String attachmentsExtension,
}) {
  const supportedExtensions = <String>{
    'docx',
    'hwp',
    'pdf',
    'ppt',
    'xlsx',
  };

  final extensionFromField = _normalizeFileExtension(attachmentsExtension);
  final extensionFromName = _normalizeFileExtension(_extractExtension(fileName));

  // 서버 확장자 필드가 일반 MIME(예: application/octet-stream)인 경우를
  // 대비해, 지원 가능한 확장자를 순서대로 탐색한다.
  final candidates = <String>[extensionFromField, extensionFromName];
  String? normalized;
  for (final candidate in candidates) {
    if (supportedExtensions.contains(candidate)) {
      normalized = candidate;
      break;
    }
  }
  if (normalized == null) return null;

  return 'assets/icons/File/$normalized.png';
}

String _normalizeFileExtension(String raw) {
  if (raw.trim().isEmpty) return '';

  var value = raw.trim().toLowerCase();
  if (value.contains(';')) {
    value = value.split(';').first.trim();
  }

  if (value.startsWith('.')) {
    value = value.substring(1);
  }

  // MIME 타입으로 내려오는 케이스 지원
  const mimeToExtension = <String, String>{
    'application/pdf': 'pdf',
    'application/haansofthwp': 'hwp',
    'application/x-hwp': 'hwp',
    'application/msword': 'docx',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        'docx',
    'application/vnd.ms-powerpoint': 'ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        'ppt',
    'application/vnd.ms-excel': 'xlsx',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        'xlsx',
  };
  if (mimeToExtension.containsKey(value)) {
    return mimeToExtension[value]!;
  }

  // 혹시 전체 파일명 형태가 들어오면 마지막 확장자만 사용
  if (value.contains('.')) {
    value = value.split('.').last;
  }

  // 확장자 별칭 정규화
  const extensionAliases = <String, String>{
    'doc': 'docx',
    'hwpx': 'hwp',
    'pptx': 'ppt',
    'xls': 'xlsx',
    'xlsm': 'xlsx',
  };
  return extensionAliases[value] ?? value;
}

String _extractExtension(String fileName) {
  final normalized = fileName.trim().toLowerCase();
  final dotIndex = normalized.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == normalized.length - 1) return '';
  return normalized.substring(dotIndex + 1);
}

String _formatFileSubtitle(String? createdAt, double attachmentsSize) {
  final dateStr = createdAt != null && createdAt.isNotEmpty
      ? _formatCreatedAt(createdAt)
      : '';
  final sizeStr = '${attachmentsSize.toStringAsFixed(1)}KB';
  return dateStr.isEmpty ? sizeStr : '$dateStr | $sizeStr';
}

// ─── 이미지 탭 (API images[]) ───
class _ImageTabContent extends ConsumerWidget {
  final List<AttachmentImageDto> images;
  final List<PendingImageUpload> pendingUploads;
  final void Function(AttachmentImageDto image) onImageLongPress;
  final void Function(AttachmentImageDto image) onImageTap;

  const _ImageTabContent({
    required this.images,
    required this.pendingUploads,
    required this.onImageLongPress,
    required this.onImageTap,
  });

  /// Figma 기준 타일 비율 (가로 / 세로)
  static const double _tileAspect = 161 / 163;

  /// 폰은 2열 유지, 매우 좁을 때만 1열, 태블릿 폭에서만 3열.
  static int _columnCountForWidth(double maxWidth, double gap) {
    if (maxWidth <= 0) return 1;
    if (maxWidth < 210) return 1;
    if (maxWidth < 520) return 2;
    final thirdW = (maxWidth - gap * 2) / 3;
    return thirdW >= 120 ? 3 : 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingItems = pendingUploads
        .expand((u) => u.items.map((item) => (item: item, upload: u)))
        .toList();
    final totalCount = pendingItems.length + images.length;

    if (totalCount == 0) {
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
    const gap = AppSpacing.sm + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionToolbar(totalCount),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final count = _columnCountForWidth(maxW, gap);
                final tileW = (maxW - gap * (count - 1)) / count;
                final tileH = tileW / _tileAspect;
                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    crossAxisSpacing: gap,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: _tileAspect,
                  ),
                  itemCount: totalCount,
                  itemBuilder: (context, index) {
                    if (index < pendingItems.length) {
                      final (:item, :upload) = pendingItems[index];
                      return _PendingImageCell(
                        width: tileW,
                        height: tileH,
                        item: item,
                        upload: upload,
                        onRetry: () => ref
                            .read(pendingUploadsProvider.notifier)
                            .retry(upload.id),
                      );
                    }
                    final img = images[index - pendingItems.length];
                    return _TapScale(
                      onTap: () => onImageTap(img),
                      onLongPress: () => onImageLongPress(img),
                      pressedScale: 0.94,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: _FolderImageCell(
                        width: tileW,
                        height: tileH,
                        image: img,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 보관함 이미지 탭 셀
class _FolderImageCell extends StatelessWidget {
  const _FolderImageCell({
    required this.width,
    required this.height,
    required this.image,
  });

  final double width;
  final double height;
  final AttachmentImageDto image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        width: width,
        height: height,
        child: image.presignedUrl.isNotEmpty
            ? Image.network(
                image.presignedUrl,
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
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.borderLight,
                ),
              )
            : Container(color: AppColors.borderLight),
      ),
    );
  }
}

/// 업로드 중/실패 pending 이미지 셀
class _PendingImageCell extends StatelessWidget {
  const _PendingImageCell({
    required this.width,
    required this.height,
    required this.item,
    required this.upload,
    required this.onRetry,
  });

  final double width;
  final double height;
  final PendingImageItem item;
  final PendingImageUpload upload;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isFailed = upload.status == PendingUploadStatus.failed;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(item.bytes, fit: BoxFit.cover),
            Container(
              color: isFailed
                  ? Colors.red.withOpacity(0.45)
                  : Colors.white.withOpacity(0.55),
            ),
            if (isFailed)
              Center(
                child: GestureDetector(
                  onTap: onRetry,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, color: Colors.white, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        '재시도',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

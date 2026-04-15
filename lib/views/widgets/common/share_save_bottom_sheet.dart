import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/home/folder_item.dart';

/// 외부 공유 진입 시 저장 바텀시트를 표시
Future<void> showShareSaveBottomSheet(
  BuildContext context, {
  required List<FolderItem> folders,
  FolderItem? initialSelectedFolder,
  String initialMemo = '',
  required Future<void> Function(FolderItem selectedFolder, String memo) onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ShareSaveBottomSheet(
      folders: folders,
      initialSelectedFolder: initialSelectedFolder,
      initialMemo: initialMemo,
      onSave: onSave,
    ),
  );
}

/// 외부 공유 진입 전용 저장 바텀시트.
class ShareSaveBottomSheet extends StatefulWidget {
  const ShareSaveBottomSheet({
    super.key,
    required this.folders,
    this.initialSelectedFolder,
    this.initialMemo = '',
    required this.onSave,
  });

  final List<FolderItem> folders;
  final FolderItem? initialSelectedFolder;
  final String initialMemo;
  final Future<void> Function(FolderItem selectedFolder, String memo) onSave;

  @override
  State<ShareSaveBottomSheet> createState() => _ShareSaveBottomSheetState();
}

class _ShareSaveBottomSheetState extends State<ShareSaveBottomSheet> {
  static const int memoMaxLength = 1000;
  static const double sheetFixedHeight = 420;
  static const double folderChipAreaHeight = 44;

  final folderSearchController = TextEditingController();
  late final TextEditingController memoController;

  FolderItem? selectedFolder;
  late List<FolderItem> displayedFolders;
  String folderQuery = '';
  int memoLength = 0;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    memoController = TextEditingController(text: widget.initialMemo);
    memoLength = widget.initialMemo.length;
    selectedFolder = widget.initialSelectedFolder ?? widget.folders.firstOrNull;
    displayedFolders = List<FolderItem>.from(widget.folders);

    folderSearchController.addListener(_handleFolderSearchChanged);
    memoController.addListener(() {
      setState(() => memoLength = memoController.text.length);
    });
  }

  @override
  void dispose() {
    folderSearchController.dispose();
    memoController.dispose();
    super.dispose();
  }

  Future<void> handleSaveTap() async {
    if (isSaving) return;
    final targetFolder = selectedFolder;
    if (targetFolder == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('보관함을 선택해 주세요.')));
      return;
    }

    setState(() => isSaving = true);
    try {
      await widget.onSave(targetFolder, memoController.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void clearFolderSearch() {
    if (folderSearchController.text.isEmpty) return;
    folderSearchController.clear();
  }

  void _handleFolderSearchChanged() {
    final nextQuery = folderSearchController.text;
    final keyword = nextQuery.trim().toLowerCase();
    final matchedFolders = keyword.isEmpty
        ? widget.folders
        : widget.folders.where((folder) {
            return folder.title.toLowerCase().contains(keyword);
          }).toList();

    setState(() {
      folderQuery = nextQuery;
      if (keyword.isEmpty || matchedFolders.isNotEmpty) {
        displayedFolders = List<FolderItem>.from(matchedFolders);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: sheetFixedHeight,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '보관함',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: handleSaveTap,
                      behavior: HitTestBehavior.opaque,
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              '저장',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: selectedFolder == null
                                    ? AppColors.neutral100
                                    : AppColors.blue500,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildFolderSearchBar(),
                const SizedBox(height: 12),
                _buildFolderChips(),
                const SizedBox(height: 20),
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
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(13),
                  child: TextField(
                    controller: memoController,
                    maxLines: null,
                    maxLength: memoMaxLength,
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
                      border: InputBorder.none,
                      hintText: '자료에 대한 정보를 간단하게 메모해보세요.',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray600,
                        letterSpacing: -0.025 * 16,
                        height: 1.5,
                      ),
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$memoLength/$memoMaxLength',
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
        ),
      ),
    );
  }

  Widget _buildFolderSearchBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, size: 28, color: AppColors.gray900),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: folderSearchController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.025 * 16,
                height: 1.4,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '보관함 입력',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                  letterSpacing: -0.025 * 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: clearFolderSearch,
            splashRadius: 20,
            icon: Icon(
              Icons.cancel_outlined,
              size: 30,
              color: folderQuery.trim().isEmpty
                  ? AppColors.neutral100
                  : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderChips() {
    return SizedBox(
      height: folderChipAreaHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayedFolders.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final folder = displayedFolders[index];
          final isSelected = selectedFolder?.foldersId == folder.foldersId;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => setState(() => selectedFolder = folder),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.blue500.withValues(alpha: 0.14)
                    : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? AppColors.blue500 : AppColors.neutral100,
                ),
              ),
              child: Text(
                folder.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.blue500 : AppColors.gray600,
                  letterSpacing: -0.025 * 16,
                  height: 1.4,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

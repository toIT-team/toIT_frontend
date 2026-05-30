import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/system_safe_area.dart';
import '../../../models/home/folder_item.dart';
import 'app_snack_bar.dart';

/// 보관함 선택 바텀시트 표시 (링크/노트/파일/이미지 저장 화면 등에서 공통 사용)
///
/// [ref]로 홈 보관함 목록을 읽어 시트를 띄움
/// 보관함이 없으면 시트는 띄우지 않고 스낵바만 표시
Future<void> showFolderPickerSheet(
  BuildContext context,
  WidgetRef ref, {
  FolderItem? selectedFolder,
  required ValueChanged<FolderItem> onSelect,
}) async {
  final folders = ref.read(homeProvider).folders;
  if (folders.isEmpty) {
    if (context.mounted) {
      showAppSnackBar(context, '보관함이 없습니다. 먼저 보관함을 만들어 주세요.');
    }
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    builder: (sheetContext) => FolderPickerSheet(
      folders: folders,
      selectedFolder: selectedFolder,
      onSelect: (folder) {
        onSelect(folder);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

/// 보관함 선택 바텀시트 본문 (재사용 가능 위젯)
///
/// [showFolderPickerSheet]에서 사용하며, 목록만 따로 쓸 경우에도 사용 가능.
class FolderPickerSheet extends StatelessWidget {
  const FolderPickerSheet({
    super.key,
    required this.folders,
    this.selectedFolder,
    required this.onSelect,
  });

  final List<FolderItem> folders;
  final FolderItem? selectedFolder;
  final ValueChanged<FolderItem> onSelect;

  @override
  Widget build(BuildContext context) {
    return SystemSafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '보관함 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                final isSelected =
                    selectedFolder?.foldersId == folder.foldersId;
                return ListTile(
                  leading: Icon(
                    Icons.folder_outlined,
                    color: folder.accentColor,
                  ),
                  title: Text(folder.title),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.blue500)
                      : null,
                  onTap: () => onSelect(folder),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import '../../models/dto/search_response_dto.dart';
import '../../models/home/folder_item.dart';
import '../constants/app_colors.dart';

/// 서버 color 문자열·iconIdx로 색상 인덱스 결정 (홈 [HomeController]와 동일 규칙)
int resolveFolderColorIndex(String colorStr, int iconIdx) {
  if (colorStr.isEmpty) {
    return iconIdx % AppColors.folderColors.length;
  }
  final tokenIdx = AppColors.folderColorTokens.indexOf(colorStr);
  if (tokenIdx != -1) return tokenIdx;
  final color = AppColors.fromColorString(colorStr);
  final colorIdx = AppColors.folderColors.indexOf(color);
  if (colorIdx != -1) return colorIdx;
  return iconIdx % AppColors.folderColors.length;
}

/// 통합 검색 API의 폴더 항목 → [FolderItem].
///
/// [homeFolders]에 동일 ID가 있으면 개수·스타일 정보를 그대로 재사용한다.
FolderItem folderItemFromSearchFolderDto(
  SearchFolderItemDto dto,
  List<FolderItem> homeFolders,
) {
  for (final f in homeFolders) {
    if (f.foldersId == dto.foldersId) {
      return f;
    }
  }
  final ci = resolveFolderColorIndex(dto.color, dto.iconIdx);
  final safeIdx =
      ci.clamp(0, AppColors.folderColors.length - 1).toInt();
  return FolderItem(
    foldersId: dto.foldersId,
    title: dto.name.isEmpty ? '보관함' : dto.name,
    memo: dto.memo,
    countText: '0개',
    colorIndex: safeIdx,
    isDefault: dto.isDefault,
    accentColor: AppColors.folderColors[safeIdx],
  );
}

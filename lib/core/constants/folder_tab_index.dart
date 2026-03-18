/// FolderDetailScreen 탭 정의
///
/// 순서 변경 시 [FolderTab.order]만 수정하면 TabBar/TabBarView 자동 반영
enum FolderTab {
  links('링크'),
  notes('노트'),
  files('파일'),
  images('이미지');

  final String label;
  const FolderTab(this.label);

  /// 탭 순서 (이 리스트만 수정하면 TabBar/TabBarView 자동 반영)
  static const List<FolderTab> order = [
    FolderTab.links,
    FolderTab.notes,
    FolderTab.files,
    FolderTab.images,
  ];

  static int indexOf(FolderTab tab) => order.indexOf(tab);
}

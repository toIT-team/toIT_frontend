/// 검색 결과 표시용 모델
///
/// API DTO를 UI 표시용으로 변환한 모델
/// 네비게이션 시 foldersId, foldersName, schedulesId, textsId 등 활용
class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.foldersId,
    this.foldersName,
    this.schedulesId,
    this.textsId,
    this.textContent,
    this.createdAt,
  });

  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final int? foldersId;
  final String? foldersName;

  /// 일정 상세 이동용
  final int? schedulesId;

  /// 노트 상세 이동용 (NoteDetailScreen에 TextDto 생성)
  final int? textsId;
  final String? textContent;
  final String? createdAt;

  /// 일정 타입 여부
  bool get isSchedule => type == SearchResultType.schedule;

  /// 링크 타입 여부
  bool get isLink => type == SearchResultType.link;

  /// 노트 타입 여부
  bool get isNote => type == SearchResultType.note;

  /// 파일 타입 여부
  bool get isFile => type == SearchResultType.file;
}

/// 검색 결과 타입
enum SearchResultType {
  folder,
  schedule,
  link,
  note,
  file,
}

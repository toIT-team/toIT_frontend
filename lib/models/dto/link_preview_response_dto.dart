/// POST /links/preview 응답 (링크 미리보기 추출)
class LinkPreviewResponseDto {
  const LinkPreviewResponseDto({
    this.linksName = '',
    this.textContent = '',
    this.linksThumbnail = '',
  });

  final String linksName;
  final String textContent;
  final String linksThumbnail;

  factory LinkPreviewResponseDto.fromJson(Map<String, dynamic> json) {
    return LinkPreviewResponseDto(
      linksName: json['linksName'] as String? ?? '',
      textContent: json['textContent'] as String? ?? '',
      linksThumbnail: json['linksThumbnail'] as String? ?? '',
    );
  }
}

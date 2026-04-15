/// 마이페이지 응답 DTO
class MyPageResponseDto {
  final String nickname;
  final String imageUrl;
  final String name;
  final String email;
  final String authProvider;
  final String appVersion;

  const MyPageResponseDto({
    required this.nickname,
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.authProvider,
    required this.appVersion,
  });

  factory MyPageResponseDto.fromJson(Map<String, dynamic> json) {
    return MyPageResponseDto(
      nickname: (json['nickname'] as String?) ?? '',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      authProvider: (json['authProvider'] as String?) ?? '',
      appVersion: (json['appVersion'] as String?) ?? '',
    );
  }
}

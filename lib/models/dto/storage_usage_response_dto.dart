/// 스토리지 사용량 응답 DTO
class StorageUsageResponseDto {
  final double imageUsedBytes;
  final double imageUsedMB;
  final double fileUsedBytes;
  final double fileUsedMB;
  final double totalUsedBytes;
  final double totalUsedMB;
  final double limitBytes;
  final double limitMB;
  final double remainingBytes;
  final double remainingMB;

  const StorageUsageResponseDto({
    required this.imageUsedBytes,
    required this.imageUsedMB,
    required this.fileUsedBytes,
    required this.fileUsedMB,
    required this.totalUsedBytes,
    required this.totalUsedMB,
    required this.limitBytes,
    required this.limitMB,
    required this.remainingBytes,
    required this.remainingMB,
  });

  factory StorageUsageResponseDto.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return 0;
    }

    return StorageUsageResponseDto(
      imageUsedBytes: toDouble(json['imageUsedBytes']),
      imageUsedMB: toDouble(json['imageUsedMB']),
      fileUsedBytes: toDouble(json['fileUsedBytes']),
      fileUsedMB: toDouble(json['fileUsedMB']),
      totalUsedBytes: toDouble(json['totalUsedBytes']),
      totalUsedMB: toDouble(json['totalUsedMB']),
      limitBytes: toDouble(json['limitBytes']),
      limitMB: toDouble(json['limitMB']),
      remainingBytes: toDouble(json['remainingBytes']),
      remainingMB: toDouble(json['remainingMB']),
    );
  }
}

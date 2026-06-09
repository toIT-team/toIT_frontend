import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';

/// CloudFront Signed Cookie를 첨부해 이미지를 로드하는 위젯
///
/// - Secure Storage에서 쿠키를 꺼내 Cookie 헤더에 첨부
/// - 403 응답 시 쿠키 재발급 후 1회 재시도
/// - Image.network() 대체용
class CloudFrontImage extends ConsumerStatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const CloudFrontImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  ConsumerState<CloudFrontImage> createState() => _CloudFrontImageState();
}

class _CloudFrontImageState extends ConsumerState<CloudFrontImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CloudFrontImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() {
        _imageBytes = null;
        _isLoading = true;
        _hasError = false;
      });
      _loadImage();
    }
  }

  Future<void> _loadImage({bool isRetry = false}) async {
    final authService = ref.read(authServiceProvider);
    final dio = Dio();

    try {
      final cookies = await authService.getCloudFrontCookies();
      final cookieHeader = cookies?.entries
          .map((e) => '${e.key}=${e.value}')
          .join('; ');

      final sw = Stopwatch()..start();
      final response = await dio.get<List<int>>(
        widget.url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: cookieHeader != null ? {'Cookie': cookieHeader} : null,
        ),
      );
      sw.stop();

      final bytes = Uint8List.fromList(response.data!);
      // x-cache: "Hit from cloudfront" / "Miss from cloudfront"
      final xCache = response.headers.value('x-cache') ?? 'unknown';
      final sizeKb = (bytes.length / 1024).toStringAsFixed(1);
      debugPrint('[이미지 측정] ${sw.elapsedMilliseconds}ms | ${sizeKb}KB | $xCache | ${widget.url}');

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      // 쿠키 만료(403) 시 재발급 후 1회 재시도
      if (e.response?.statusCode == 403 && !isRetry) {
        final success = await authService.fetchAndSaveCloudFrontCookies();
        if (success) {
          await _loadImage(isRetry: true);
          return;
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    }

    if (_hasError || _imageBytes == null) {
      return widget.errorWidget ?? const SizedBox.shrink();
    }

    return Image.memory(_imageBytes!, fit: widget.fit);
  }
}

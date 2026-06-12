import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// S3 Presigned URL 이미지 표시 위젯 (화면 표시 전용)
/// 측정은 S3BenchService.run()이 전담한다. 이 위젯은 그리드에 이미지만 보여준다.
/// bench/s3-compare 브랜치 전용
class S3BenchmarkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const S3BenchmarkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<S3BenchmarkImage> createState() => _S3BenchmarkImageState();
}

class _S3BenchmarkImageState extends State<S3BenchmarkImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(S3BenchmarkImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      setState(() {
        _imageBytes = null;
        _isLoading = true;
        _hasError = false;
      });
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    // 화면 표시용 로드 (측정 아님). 측정은 S3BenchService.run()이 담당.
    final dio = Dio();
    try {
      final response = await dio.get<List<int>>(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[S3 표시] ERROR | $e | ${widget.url}');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } finally {
      dio.close();
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

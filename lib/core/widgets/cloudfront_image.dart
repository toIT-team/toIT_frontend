import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  static const int _kBenchmarkRuns = 100;
  static final List<int> _hitMs = [];

  // 화면에 마운트된 위젯 수와 첫 로드 완료 수를 추적해
  // 모든 이미지의 첫 로드(MISS)가 끝난 뒤에야 벤치마크를 시작한다.
  static int _mountedCount = 0;
  static int _initialLoadDoneCount = 0;
  static Completer<void>? _allLoadedCompleter;
  static Future<void> _benchmarkChain = Future.value();

  static String _pctSummary() {
    if (_hitMs.isEmpty) return 'n=0';
    final s = [..._hitMs]..sort();
    int p(double pct) => s[((s.length - 1) * pct).round()];
    return 'n=${s.length} p50=${p(.50)}ms p95=${p(.95)}ms p99=${p(.99)}ms';
  }

  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;
  bool _benchmarkStarted = false;

  @override
  void initState() {
    super.initState();
    if (_mountedCount == 0) {
      _allLoadedCompleter = Completer<void>();
      _initialLoadDoneCount = 0;
      _benchmarkChain = _allLoadedCompleter!.future;
    }
    _mountedCount++;
    _loadImage();
  }

  @override
  void dispose() {
    _mountedCount--;
    super.dispose();
  }

  @override
  void didUpdateWidget(CloudFrontImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() {
        _imageBytes = null;
        _isLoading = true;
        _hasError = false;
        _benchmarkStarted = false;
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
      final elapsedMs = sw.elapsedMilliseconds;
      if (xCache.contains('Hit')) {
        _hitMs.add(elapsedMs);
        debugPrint('[이미지 측정] HIT  | ${elapsedMs}ms | ${sizeKb}KB | ${_pctSummary()} | ${widget.url}');
      } else {
        debugPrint('[이미지 측정] MISS | ${elapsedMs}ms | ${sizeKb}KB (400px) | ${widget.url}');
        await _logOriginalSize(dio, cookieHeader);
      }

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      }

      if (!_benchmarkStarted) {
        _benchmarkStarted = true;
        _initialLoadDoneCount++;
        final completer = _allLoadedCompleter;
        if (completer != null &&
            !completer.isCompleted &&
            _initialLoadDoneCount >= _mountedCount) {
          completer.complete();
        }
        _benchmarkChain = _benchmarkChain.then((_) => _runBenchmark());
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

  // /resize/{n}/ 를 제거해 원본 URL 복원, 없으면 null
  String? _originalUrl() {
    final match = RegExp(r'/resize/\d+').firstMatch(widget.url);
    if (match == null) return null;
    return widget.url.replaceFirst(match.group(0)!, '');
  }

  Future<void> _logOriginalSize(Dio dio, String? cookieHeader) async {
    final origUrl = _originalUrl();
    if (origUrl == null) return;
    try {
      // HEAD로 content-length만 확인
      final head = await dio.head<void>(
        origUrl,
        options: Options(
          headers: cookieHeader != null ? {'Cookie': cookieHeader} : null,
        ),
      );
      final cl = int.tryParse(head.headers.value('content-length') ?? '');
      if (cl != null) {
        debugPrint('[이미지 원본] ${(cl / 1024).toStringAsFixed(1)}KB | $origUrl');
        return;
      }
    } catch (_) {}
    // HEAD에 content-length 없으면 GET으로 실제 크기 측정
    try {
      final resp = await dio.get<List<int>>(
        origUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: cookieHeader != null ? {'Cookie': cookieHeader} : null,
        ),
      );
      final size = resp.data?.length ?? 0;
      debugPrint('[이미지 원본] ${(size / 1024).toStringAsFixed(1)}KB | $origUrl');
    } catch (_) {
      debugPrint('[이미지 원본] 크기 조회 실패 | $origUrl');
    }
  }

  Future<void> _runBenchmark() async {
    final authService = ref.read(authServiceProvider);
    final cookies = await authService.getCloudFrontCookies();
    final cookieHeader = cookies?.entries
        .map((e) => '${e.key}=${e.value}')
        .join('; ');
    final dio = Dio();

    // 웜업
    const warmupRuns = 5;
    debugPrint('[웜업 시작] ${warmupRuns}회 | ${widget.url}');
    for (int i = 0; i < warmupRuns; i++) {
      if (!mounted) break;
      try {
        final sw = Stopwatch()..start();
        await dio.get<List<int>>(
          widget.url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: cookieHeader != null ? {'Cookie': cookieHeader} : null,
          ),
        );
        sw.stop();
        debugPrint('[웜업] ${i + 1}/$warmupRuns | ${sw.elapsedMilliseconds}ms');
      } catch (_) {
        debugPrint('[웜업] ${i + 1}/$warmupRuns ERROR');
      }
    }
    debugPrint('[웜업 완료] ${widget.url}');

    debugPrint('[벤치마크 시작] ${_kBenchmarkRuns}회 | ${widget.url}');

    for (int i = 0; i < _kBenchmarkRuns; i++) {
      if (!mounted) break;
      try {
        final sw = Stopwatch()..start();
        final response = await dio.get<List<int>>(
          widget.url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: cookieHeader != null ? {'Cookie': cookieHeader} : null,
          ),
        );
        sw.stop();

        final xCache = response.headers.value('x-cache') ?? 'unknown';
        final elapsedMs = sw.elapsedMilliseconds;
        final sizeKb = (response.data!.length / 1024).toStringAsFixed(1);

        if (xCache.contains('Hit')) {
          _hitMs.add(elapsedMs);
          debugPrint('[벤치마크] ${i + 1}/$_kBenchmarkRuns | ${elapsedMs}ms | ${sizeKb}KB | ${_pctSummary()}');
        } else {
          debugPrint('[벤치마크] ${i + 1}/$_kBenchmarkRuns MISS | ${elapsedMs}ms | ${sizeKb}KB');
        }
      } catch (_) {
        debugPrint('[벤치마크] ${i + 1}/$_kBenchmarkRuns ERROR');
      }
    }

    debugPrint('[벤치마크 완료] ${widget.url} | ${_pctSummary()}');
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/pending_save_item.dart';
import '../../../providers/pending_uploads_provider.dart';

/// 이미지 업로드 진행 중 하단에 떠오르는 플로팅 카드 배너.
///
/// [pendingUploadsProvider]를 직접 구독해 업로드 여부·진행률을 판단하므로,
/// 호출부는 위치만 잡아 두면 표시/숨김과 슬라이드 애니메이션을 스스로 처리한다.
/// 네비게이션 쉘(네비바 위)과 보관함 상세(+버튼 위)에서 공통으로 쓴다.
///
/// 진행률은 S3 바이트 전송과 분리된 UI 애니메이션으로 표시한다.
/// (실제 업로드 속도를 유지하기 위해 전송은 통째로 보내고, 표시만 부드럽게 올린다.)
class UploadProgressBanner extends ConsumerStatefulWidget {
  const UploadProgressBanner({super.key, this.bottomInset = 16});

  /// 카드 하단과 부모 하단 사이 여백. 네비바·FAB 등을 비켜 가도록 조정한다.
  final double bottomInset;

  @override
  ConsumerState<UploadProgressBanner> createState() =>
      _UploadProgressBannerState();
}

class _UploadProgressBannerState extends ConsumerState<UploadProgressBanner>
    with TickerProviderStateMixin {
  static const String _title = '저장 중';
  static const String _subtitle = '앱을 종료하지 말아주세요.';

  /// 슬라이드/페이드 등장·퇴장
  late final AnimationController _slideController;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  /// 업로드 중 표시용 진행률 (0.0~0.9). 완료 전 100%에 닿지 않게 한다.
  late final AnimationController _progressController;
  late final Animation<double> _progressAnim;

  /// 화면에 표시할 진행률. 완료 시 1.0으로 스냅 후 퇴장한다.
  double _displayProgress = 0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );
    _fade = CurvedAnimation(parent: _slideController, curve: Curves.easeOut);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    );
    _progressController.addListener(_syncProgressDuringUpload);

    // 앱 재시작 후 업로드 복구 시에도 배너를 표시한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isUploading(ref.read(pendingUploadsProvider))) {
        _startUpload();
      }
    });
  }

  @override
  void dispose() {
    _progressController.removeListener(_syncProgressDuringUpload);
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  bool _isUploading(List<PendingSaveItem> uploads) {
    return uploads.any((u) => u.status == PendingSaveStatus.uploading);
  }

  void _syncProgressDuringUpload() {
    if (!mounted || _isDismissing) return;
    setState(() {
      _displayProgress = (_progressAnim.value * 0.9).clamp(0.0, 0.9);
    });
  }

  void _startUpload() {
    _isDismissing = false;
    _displayProgress = 0;
    _progressController.forward(from: 0);
    _slideController.forward();
  }

  Future<void> _completeAndDismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    _progressController.stop();
    setState(() => _displayProgress = 1.0);
    await _slideController.reverse();
    if (!mounted) return;
    _progressController.reset();
    _isDismissing = false;
    setState(() => _displayProgress = 0);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<PendingSaveItem>>(pendingUploadsProvider, (
      previous,
      next,
    ) {
      final wasUploading = _isUploading(previous ?? const []);
      final isUploading = _isUploading(next);
      if (isUploading && !wasUploading) {
        _startUpload();
      } else if (!isUploading && wasUploading) {
        unawaited(_completeAndDismiss());
      }
    });

    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _progressController]),
      builder: (context, child) {
        if (_slideController.isDismissed) return const SizedBox.shrink();
        return IgnorePointer(
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, widget.bottomInset),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: _BannerCard(progress: _displayProgress),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral50),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowCard,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _CircularPercent(progress: progress),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _UploadProgressBannerState._title,
                  style: TextStyle(
                    color: AppColors.gray900,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.025 * 15,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _UploadProgressBannerState._subtitle,
                  style: TextStyle(
                    color: AppColors.gray600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.025 * 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 원형 진행 표시 + 가운데 퍼센트 숫자.
class _CircularPercent extends StatelessWidget {
  const _CircularPercent({required this.progress});

  final double progress;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round().clamp(0, 100);
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: _size,
            height: _size,
            child: CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 4,
              backgroundColor: AppColors.neutral100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.blue500,
              ),
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: AppColors.blue500,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

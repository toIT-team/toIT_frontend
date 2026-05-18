import 'package:flutter/material.dart';

OverlayEntry? _currentToastEntry;
String? _currentToastMessage;

/// 하단 고정형 토스트를 표시한다.
///
/// - 하단에서 위로 올라왔다가 내려가는 애니메이션을 사용
/// - 디자인: 둥근 모서리 8px, 회색 배경, 흰색 텍스트
void showAppToast(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  if (_currentToastEntry != null && _currentToastMessage == message) {
    return;
  }

  _currentToastEntry?.remove();
  _currentToastEntry = null;
  _currentToastMessage = null;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) => _AppToastOverlay(
      message: message,
      duration: duration,
      onCompleted: () {
        if (entry.mounted) {
          entry.remove();
        }
        if (identical(_currentToastEntry, entry)) {
          _currentToastEntry = null;
          _currentToastMessage = null;
        }
      },
    ),
  );

  _currentToastEntry = entry;
  _currentToastMessage = message;
  overlay.insert(entry);
}

class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    required this.message,
    required this.duration,
    required this.onCompleted,
  });

  final String message;
  final Duration duration;
  final VoidCallback onCompleted;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );
    _play();
  }

  Future<void> _play() async {
    await _controller.forward();
    await Future<void>.delayed(widget.duration);
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) {
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SlideTransition(
                position: _slideAnimation,
                child: Material(
                  color: const Color(0xFF7E7E7E),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import 'auth_controller.dart';

/// 스플래시 부트스트랩 단계의 상태.
///
/// 앱이 켜지고 나서 "첫 화면을 어디로 보낼지" 결정하기까지의
/// 내부 상태 머신이다. `authProvider` 는 최종 인증 여부만 담당하고,
/// 여기서는 "부트스트랩이 끝났는가" 와 "일시적 오류 중인가" 를 담당한다.
enum BootstrapStatus {
  /// 아직 한 번도 실행되지 않음. 앱 시작 직후.
  idle,

  /// 부트스트랩 진행 중 (토큰 확인 + 선제 재발급).
  running,

  /// 인증 성공. 홈으로 진입 가능.
  authenticated,

  /// 토큰이 없거나 재발급 실패. 로그인 화면으로 이동.
  unauthenticated,

  /// 네트워크/타임아웃 등 일시적 오류. 사용자가 재시도 가능.
  retryable,
}

/// 부트스트랩 상태와 함께 마지막 오류 메시지를 담는다.
///
/// 메시지는 운영/디버깅용이며, UI 에는 설계서의 정형 문구를 사용한다.
class BootstrapState {
  final BootstrapStatus status;
  final String? errorMessage;

  const BootstrapState({this.status = BootstrapStatus.idle, this.errorMessage});

  BootstrapState copyWith({BootstrapStatus? status, String? errorMessage}) {
    return BootstrapState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

/// 스플래시에서 수행하는 부트스트랩 시퀀스를 관리하는 Notifier.
///
/// 책임:
/// 1) 로컬 토큰 쌍 유무 확인 (`AuthService.hasTokens`)
/// 2) 토큰이 있으면 접속 전 선제 재발급 시도 (`AuthService.reissueAccessToken`)
/// 3) 성공 시 기존 `AuthController.checkAuthStatus` 를 재활용해
///    `authProvider` 의 인증 상태·userId·FCM 등록·AppGroup 동기화를 일괄 수행
///
/// 정책:
/// - 전체 시퀀스에 5초 타임아웃. 초과 시 `retryable` 로 전환하고
///   토큰은 유지한다 (네트워크 회복 후 재시도 가능하도록).
/// - `_isRunning` 단일 실행 락으로 중복 호출을 막는다.
///   (스플래시 빌드 중 발생하는 rebuild 로 인한 중복 기동 방지)
class BootstrapController extends Notifier<BootstrapState> {
  /// 전체 부트스트랩 시퀀스가 넘어서는 안 되는 한계 시간.
  ///
  /// 네트워크 지연이 이 값을 넘으면 "다시 시도" 를 유도하는 편이
  /// 무한 로딩보다 UX 상 낫다는 판단.
  static const _bootstrapTimeout = Duration(seconds: 5);

  /// 재진입 방지용 플래그. run/retry 가 동시에 들어와도 1회만 수행된다.
  bool _isRunning = false;

  @override
  BootstrapState build() => const BootstrapState();

  AuthService get _authService => ref.read(authServiceProvider);
  AuthController get _authController => ref.read(authProvider.notifier);

  /// 부트스트랩을 1회 실행한다.
  ///
  /// 이미 실행 중이면 무시되고, 결과는 `state` 로만 전달된다.
  ///
  /// 전 구간 경과 시간을 [Stopwatch] 로 재서 `bootstrap_end` 로그에
  /// `elapsedMs` 로 기록한다. 이 수치는 추후 p50/p95 지표화의 원시 데이터가 된다.
  Future<void> run() async {
    if (_isRunning) {
      debugPrint('[BOOT] run_ignored reason=already_running');
      return;
    }
    _isRunning = true;
    state = const BootstrapState(status: BootstrapStatus.running);
    final stopwatch = Stopwatch()..start();
    debugPrint(
      '[BOOT] bootstrap_start '
      'timeoutMs=${_bootstrapTimeout.inMilliseconds}',
    );

    try {
      await _executeSequence().timeout(_bootstrapTimeout);
    } on TimeoutException {
      stopwatch.stop();
      debugPrint(
        '[BOOT] bootstrap_end result=retryable reason=timeout '
        'elapsedMs=${stopwatch.elapsedMilliseconds}',
      );
      state = const BootstrapState(
        status: BootstrapStatus.retryable,
        errorMessage: 'bootstrap-timeout',
      );
      return;
    } catch (e, st) {
      stopwatch.stop();
      debugPrint(
        '[BOOT] bootstrap_end result=retryable reason=exception '
        'error=$e elapsedMs=${stopwatch.elapsedMilliseconds}',
      );
      debugPrint('[BOOT] stackTrace: $st');
      state = BootstrapState(
        status: BootstrapStatus.retryable,
        errorMessage: e.toString(),
      );
      return;
    } finally {
      _isRunning = false;
    }

    stopwatch.stop();
    debugPrint(
      '[BOOT] bootstrap_end result=${state.status.name} '
      'elapsedMs=${stopwatch.elapsedMilliseconds}',
    );
  }

  /// 재시도 화면에서 "다시 시도" 를 눌렀을 때 호출.
  Future<void> retry() {
    debugPrint('[BOOT] retry_requested');
    return run();
  }

  /// 부트스트랩 본 절차.
  ///
  /// 각 분기 끝에서 `state` 를 확정 상태로 바꾸며,
  /// 실패 경로에서는 기존 `AuthController` 의 로그아웃 경로를 재활용한다.
  /// 단계별 `*_start/*_end` 로그를 남겨 외부에서 어느 구간이 느렸는지
  /// 즉시 식별할 수 있도록 한다.
  Future<void> _executeSequence() async {
    debugPrint('[BOOT] checkTokenPair_start');
    final hasLocalTokens = await _authService.hasTokens();
    debugPrint('[BOOT] checkTokenPair_end hasTokens=$hasLocalTokens');

    if (!hasLocalTokens) {
      debugPrint('[BOOT] route=unauthenticated reason=no_local_tokens');
      await _authController.checkAuthStatus();
      state = const BootstrapState(status: BootstrapStatus.unauthenticated);
      return;
    }

    debugPrint('[BOOT] reissue_start');
    final reissueStopwatch = Stopwatch()..start();
    final newAccessToken = await _authService.reissueAccessToken();
    reissueStopwatch.stop();
    debugPrint(
      '[BOOT] reissue_end status=${newAccessToken == null ? 'fail' : 'success'} '
      'elapsedMs=${reissueStopwatch.elapsedMilliseconds}',
    );

    if (newAccessToken == null) {
      // 재발급 실패 = refresh 만료 또는 서버 401. 보수적으로 로그아웃 처리.
      // 네트워크 일시 오류는 외부 타임아웃이 먼저 잡아서 retryable 로 빠진다.
      debugPrint('[BOOT] route=unauthenticated reason=reissue_failed');
      await _authController.forceLogout();
      state = const BootstrapState(status: BootstrapStatus.unauthenticated);
      return;
    }

    // 재발급 성공. 기존 인증 복원 루틴(userId/AppGroup/FCM) 재사용.
    debugPrint('[BOOT] restoreSession_start');
    await _authController.checkAuthStatus();
    debugPrint('[BOOT] restoreSession_end');
    state = const BootstrapState(status: BootstrapStatus.authenticated);
    debugPrint('[BOOT] route=authenticated');
  }
}

/// 부트스트랩 Provider.
///
/// 실제 실행은 `main.dart` 의 `_initAuth` 에서 `run()` 을 호출해 트리거한다.
final bootstrapProvider = NotifierProvider<BootstrapController, BootstrapState>(
  BootstrapController.new,
);

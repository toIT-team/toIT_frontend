import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/home_repository.dart';
import '../services/auth_service.dart';
import 'auth_controller.dart';
import 'home_controller.dart';

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
  /// 재발급(3~5s) + 핵심 데이터 선요청(2~4s)이 순차로 발생할 수 있으므로
  /// 설계서 기준 8초로 상한을 둔다. 이 값을 넘으면 "다시 시도" 화면으로 전환된다.
  static const _bootstrapTimeout = Duration(seconds: 8);

  /// 선요청(홈 데이터) 개별 타임아웃.
  ///
  /// 전체 상한보다 짧게 두어 단일 API 가 끝까지 끌지 않도록 한다.
  /// 실패/타임아웃은 "부분 실패" 로 간주하고 메인 진입은 허용한다.
  static const _prefetchTimeout = Duration(seconds: 3);

  /// 재진입 방지용 플래그. run/retry 가 동시에 들어와도 1회만 수행된다.
  bool _isRunning = false;

  /// 실행 세대 번호. `run()` 이 호출될 때마다 증가한다.
  ///
  /// `Future.timeout` 은 내부 future 를 취소하지 못하므로, 전체 타임아웃 이후에도
  /// `_executeSequence` 는 백그라운드에서 완주할 수 있다. 이때 늦게 도착한 응답이
  /// `retryable` 로 확정된 state 를 authenticated 로 덮어쓰지 못하도록,
  /// state 쓰기 직전에 현재 세대와 일치하는지 확인한다.
  int _runGeneration = 0;

  /// ---- DEBUG ONLY: 부트스트랩 시나리오 강제 주입 훅 ----
  ///
  /// `--dart-define=BOOT_SCENARIO=<id>` 로 켜며, `kDebugMode` 에서만 동작한다.
  /// 검증이 끝나면 이 블록(필드/메서드 + 호출부)을 함께 제거할 예정.
  ///
  /// 지원 시나리오:
  /// - `authenticated`     : 실네트워크 호출 없이 authenticated 로 종료
  /// - `unauthenticated`   : 실네트워크 호출 없이 unauthenticated 로 종료
  /// - `reissue_fail`      : 재발급을 강제로 실패(401 상당) 처리 → forceLogout → unauthenticated
  /// - `reissue_timeout`   : 재발급 단계에서 전체 타임아웃 초과 → retryable
  /// - `prefetch_timeout`  : prefetch 단계에서 개별 타임아웃 초과(authenticated 유지)
  /// - `prefetch_error`    : prefetch 단계에서 강제 예외(authenticated 유지)
  /// - `bootstrap_timeout` : prefetch 단계에서 전체 타임아웃 초과 → retryable
  static const _debugScenario = String.fromEnvironment('BOOT_SCENARIO');

  @override
  BootstrapState build() => const BootstrapState();

  AuthService get _authService => ref.read(authServiceProvider);
  AuthController get _authController => ref.read(authProvider.notifier);
  HomeRepository get _homeRepository => ref.read(homeRepositoryProvider);

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
    final generation = ++_runGeneration;
    state = const BootstrapState(status: BootstrapStatus.running);
    final stopwatch = Stopwatch()..start();
    debugPrint(
      '[BOOT] bootstrap_start '
      'timeoutMs=${_bootstrapTimeout.inMilliseconds} gen=$generation',
    );

    try {
      await _executeSequence(generation).timeout(_bootstrapTimeout);
    } on TimeoutException {
      stopwatch.stop();
      // 현재 세대를 즉시 무효화해서, 뒤늦게 완주하는 내부 await 가
      // state/prefetch 를 덮어쓰지 못하도록 좀비 전환을 차단한다.
      _runGeneration++;
      debugPrint(
        '[BOOT] bootstrap_end result=retryable reason=timeout '
        'elapsedMs=${stopwatch.elapsedMilliseconds} '
        'gen=$generation invalidated_to=$_runGeneration',
      );
      state = const BootstrapState(
        status: BootstrapStatus.retryable,
        errorMessage: 'bootstrap-timeout',
      );
      return;
    } catch (e, st) {
      stopwatch.stop();
      _runGeneration++;
      debugPrint(
        '[BOOT] bootstrap_end result=retryable reason=exception '
        'error=$e elapsedMs=${stopwatch.elapsedMilliseconds} '
        'gen=$generation invalidated_to=$_runGeneration',
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
  Future<void> _executeSequence(int generation) async {
    // DEBUG ONLY: 시나리오가 지정되면 실제 경로 대신 강제 분기한다.
    if (kDebugMode && _debugScenario.isNotEmpty) {
      final handled = await _runDebugScenarioBeforeSequence(generation);
      if (handled) return;
    }

    debugPrint('[BOOT] checkTokenPair_start');
    final hasLocalTokens = await _authService.hasTokens();
    debugPrint('[BOOT] checkTokenPair_end hasTokens=$hasLocalTokens');
    if (_isStale(generation, stage: 'checkTokenPair_end')) return;

    if (!hasLocalTokens) {
      debugPrint('[BOOT] route=unauthenticated reason=no_local_tokens');
      await _authController.checkAuthStatus();
      _setStateIfActive(
        generation,
        const BootstrapState(status: BootstrapStatus.unauthenticated),
      );
      return;
    }

    debugPrint('[BOOT] reissue_start');
    final reissueStopwatch = Stopwatch()..start();
    // DEBUG ONLY: `reissue_fail` 시나리오는 실제 호출을 생략하고 401 상당(=null)을 반환해
    // 이후 forceLogout → unauthenticated 경로를 검증한다.
    final newAccessToken = (kDebugMode && _debugScenario == 'reissue_fail')
        ? _forceReissueFailForDebug()
        : await _authService.reissueAccessToken();
    reissueStopwatch.stop();
    debugPrint(
      '[BOOT] reissue_end status=${newAccessToken == null ? 'fail' : 'success'} '
      'elapsedMs=${reissueStopwatch.elapsedMilliseconds}',
    );
    if (_isStale(generation, stage: 'reissue_end')) return;

    if (newAccessToken == null) {
      // 재발급 실패 = refresh 만료 또는 서버 401. 보수적으로 로그아웃 처리.
      // 네트워크 일시 오류는 외부 타임아웃이 먼저 잡아서 retryable 로 빠진다.
      debugPrint('[BOOT] route=unauthenticated reason=reissue_failed');
      await _authController.forceLogout();
      _setStateIfActive(
        generation,
        const BootstrapState(status: BootstrapStatus.unauthenticated),
      );
      return;
    }

    // 재발급 성공. 기존 인증 복원 루틴(userId/AppGroup/FCM) 재사용.
    debugPrint('[BOOT] restoreSession_start');
    await _authController.checkAuthStatus();
    debugPrint('[BOOT] restoreSession_end');
    if (_isStale(generation, stage: 'restoreSession_end')) return;

    // 메인 첫 화면(홈) 데이터 선요청.
    // 부분 실패는 허용한다. 선요청이 실패해도 메인 진입을 막지 않고,
    // 홈 화면이 띄워진 후 `HomeController` 가 자체 로드 경로로 재요청한다.
    await _prefetchHomeData(generation);
    if (_isStale(generation, stage: 'prefetch_home_end')) return;

    _setStateIfActive(
      generation,
      const BootstrapState(status: BootstrapStatus.authenticated),
    );
    debugPrint('[BOOT] route=authenticated');
  }

  /// 현재 `generation` 이 최신이 아니면 true 를 반환한다(= 늦게 도착한 좀비 실행).
  ///
  /// 해당 stage 로그를 남겨 "어디에서 차단되었는지" 추적 가능하게 한다.
  bool _isStale(int generation, {required String stage}) {
    if (generation == _runGeneration) return false;
    debugPrint(
      '[BOOT] stage_aborted stage=$stage '
      'gen=$generation current=$_runGeneration',
    );
    return true;
  }

  /// 현재 `generation` 이 최신일 때만 state 를 갱신한다.
  void _setStateIfActive(int generation, BootstrapState next) {
    if (generation != _runGeneration) {
      debugPrint(
        '[BOOT] state_write_ignored '
        'gen=$generation current=$_runGeneration target=${next.status.name}',
      );
      return;
    }
    state = next;
  }

  /// 홈 데이터(`/page/home`) 선요청. 성공 시 `homePrefetchProvider` 에 주입해
  /// 이후 `HomeController` 가 네트워크 재호출 없이 즉시 렌더되도록 한다.
  ///
  /// 개별 타임아웃(`_prefetchTimeout`)과 부분 실패 허용 정책에 따라,
  /// 이 메서드는 예외를 밖으로 던지지 않는다. 외부 상한(`_bootstrapTimeout`)
  /// 안에서만 동작하도록 보장된다.
  Future<void> _prefetchHomeData(int generation) async {
    debugPrint('[BOOT] prefetch_home_start');
    final stopwatch = Stopwatch()..start();
    try {
      // DEBUG ONLY: prefetch 단계에 시나리오를 주입한다.
      if (kDebugMode && _debugScenario.isNotEmpty) {
        await _runDebugScenarioInPrefetch();
      }

      final now = DateTime.now();
      final todayDate =
          '${now.year}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final dto = await _homeRepository
          .fetchHomeData(todayDate: todayDate)
          .timeout(_prefetchTimeout);
      // 늦게 도착한 성공 응답이 이미 취소된(retryable 등) 세션의 캐시를 오염시키지 않도록 가드.
      if (generation != _runGeneration) {
        stopwatch.stop();
        debugPrint(
          '[BOOT] prefetch_home_end status=stale '
          'elapsedMs=${stopwatch.elapsedMilliseconds} '
          'gen=$generation current=$_runGeneration',
        );
        return;
      }
      ref.read(homePrefetchProvider.notifier).state = dto;
      stopwatch.stop();
      debugPrint(
        '[BOOT] prefetch_home_end status=success '
        'elapsedMs=${stopwatch.elapsedMilliseconds} '
        'schedules=${dto.schedules.length} folders=${dto.folders.length}',
      );
    } on TimeoutException {
      stopwatch.stop();
      debugPrint(
        '[BOOT] prefetch_home_end status=timeout '
        'elapsedMs=${stopwatch.elapsedMilliseconds}',
      );
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '[BOOT] prefetch_home_end status=fail error=$e '
        'elapsedMs=${stopwatch.elapsedMilliseconds}',
      );
    }
  }

  /// DEBUG ONLY: `_executeSequence` 초입에 시나리오를 적용한다.
  ///
  /// - `authenticated` / `unauthenticated` 는 여기서 상태를 확정하고 `true` 반환(이후 절차 스킵).
  /// - `reissue_timeout` 은 전체 타임아웃을 트리거하기 위해 충분히 긴 대기만 걸고 `false` 반환.
  /// - 그 외(prefetch 계열)는 `_prefetchHomeData` 쪽 훅에서 처리한다.
  Future<bool> _runDebugScenarioBeforeSequence(int generation) async {
    debugPrint('[BOOT] debug_scenario=$_debugScenario phase=before_sequence');
    switch (_debugScenario) {
      case 'authenticated':
        _setStateIfActive(
          generation,
          const BootstrapState(status: BootstrapStatus.authenticated),
        );
        return true;
      case 'unauthenticated':
        _setStateIfActive(
          generation,
          const BootstrapState(status: BootstrapStatus.unauthenticated),
        );
        return true;
      case 'reissue_timeout':
        await Future<void>.delayed(
          _bootstrapTimeout + const Duration(seconds: 2),
        );
        return false;
      default:
        return false;
    }
  }

  /// DEBUG ONLY: prefetch 단계에서 시나리오를 적용한다.
  ///
  /// - `prefetch_timeout` : `_prefetchTimeout` 을 초과하도록 대기 → 내부 timeout 발동
  /// - `prefetch_error`   : 강제 예외 → 내부 catch 에서 fail 로그
  /// - `bootstrap_timeout`: `_bootstrapTimeout` 을 초과하도록 대기 → 외부 run() timeout 발동
  Future<void> _runDebugScenarioInPrefetch() async {
    debugPrint('[BOOT] debug_scenario=$_debugScenario phase=prefetch');
    switch (_debugScenario) {
      case 'prefetch_timeout':
        await Future<void>.delayed(
          _prefetchTimeout + const Duration(seconds: 2),
        ).timeout(_prefetchTimeout);
        break;
      case 'prefetch_error':
        throw StateError('forced prefetch error (BOOT_SCENARIO)');
      case 'bootstrap_timeout':
        await Future<void>.delayed(
          _bootstrapTimeout + const Duration(seconds: 2),
        );
        break;
    }
  }

  /// DEBUG ONLY: 재발급 실패를 시뮬레이션한다. 실제 네트워크 호출 없이 `null` 반환.
  ///
  /// 이후 `_executeSequence` 는 `reissue_end status=fail` 로그를 남기고
  /// `forceLogout → unauthenticated` 경로를 그대로 재사용한다.
  String? _forceReissueFailForDebug() {
    debugPrint('[BOOT] debug_scenario=$_debugScenario phase=reissue');
    return null;
  }
}

/// 부트스트랩 Provider.
///
/// 실제 실행은 `main.dart` 의 `_initAuth` 에서 `run()` 을 호출해 트리거한다.
final bootstrapProvider = NotifierProvider<BootstrapController, BootstrapState>(
  BootstrapController.new,
);

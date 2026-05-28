import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/home_repository.dart';
import '../services/auth_service.dart';
import '../services/schedule_api_client.dart';
import 'auth_controller.dart';
import 'calendar_controller.dart';
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

  @override
  BootstrapState build() => const BootstrapState();

  AuthService get _authService => ref.read(authServiceProvider);
  AuthController get _authController => ref.read(authProvider.notifier);
  HomeRepository get _homeRepository => ref.read(homeRepositoryProvider);
  ScheduleApiClient get _scheduleApiClient =>
      ref.read(scheduleApiClientProvider);

  /// 부트스트랩을 1회 실행한다.
  ///
  /// 이미 실행 중이면 무시되고, 결과는 `state` 로만 전달된다.
  ///
  /// 전 구간 경과 시간을 [Stopwatch] 로 재서 `bootstrap_end` 로그에
  /// `elapsedMs` 로 기록한다. 이 수치는 추후 p50/p95 지표화의 원시 데이터가 된다.
  Future<void> run() async {
    if (_isRunning) {
      // debugPrint('[BOOT] run_ignored reason=already_running');
      return;
    }
    _isRunning = true;
    final generation = ++_runGeneration;
    state = const BootstrapState(status: BootstrapStatus.running);
    final stopwatch = Stopwatch()..start();
    // debugPrint(
      // '[BOOT] bootstrap_start '
      // 'timeoutMs=${_bootstrapTimeout.inMilliseconds} gen=$generation',
    // );

    try {
      await _executeSequence(generation).timeout(_bootstrapTimeout);
    } on TimeoutException {
      stopwatch.stop();
      // 현재 세대를 즉시 무효화해서, 뒤늦게 완주하는 내부 await 가
      // state/prefetch 를 덮어쓰지 못하도록 좀비 전환을 차단한다.
      _runGeneration++;
      // debugPrint(
        // '[BOOT] bootstrap_end result=retryable reason=timeout '
        // 'elapsedMs=${stopwatch.elapsedMilliseconds} '
        // 'gen=$generation invalidated_to=$_runGeneration',
      // );
      state = const BootstrapState(
        status: BootstrapStatus.retryable,
        errorMessage: 'bootstrap-timeout',
      );
      return;
    } catch (e, st) {
      stopwatch.stop();
      _runGeneration++;
      // debugPrint(
        // '[BOOT] bootstrap_end result=retryable reason=exception '
        // 'error=$e elapsedMs=${stopwatch.elapsedMilliseconds} '
        // 'gen=$generation invalidated_to=$_runGeneration',
      // );
      // debugPrint('[BOOT] stackTrace: $st');
      state = BootstrapState(
        status: BootstrapStatus.retryable,
        errorMessage: e.toString(),
      );
      return;
    } finally {
      _isRunning = false;
    }

    stopwatch.stop();
    // debugPrint(
      // '[BOOT] bootstrap_end result=${state.status.name} '
      // 'elapsedMs=${stopwatch.elapsedMilliseconds}',
    // );
  }

  /// 재시도 화면에서 "다시 시도" 를 눌렀을 때 호출.
  Future<void> retry() {
    // debugPrint('[BOOT] retry_requested');
    return run();
  }

  /// 부트스트랩 본 절차.
  ///
  /// 각 분기 끝에서 `state` 를 확정 상태로 바꾸며,
  /// 실패 경로에서는 기존 `AuthController` 의 로그아웃 경로를 재활용한다.
  /// 단계별 `*_start/*_end` 로그를 남겨 외부에서 어느 구간이 느렸는지
  /// 즉시 식별할 수 있도록 한다.
  Future<void> _executeSequence(int generation) async {
    // debugPrint('[BOOT] checkTokenPair_start');
    final hasLocalTokens = await _authService.hasTokens();
    // debugPrint('[BOOT] checkTokenPair_end hasTokens=$hasLocalTokens');
    if (_isStale(generation, stage: 'checkTokenPair_end')) return;

    if (!hasLocalTokens) {
      // debugPrint('[BOOT] route=unauthenticated reason=no_local_tokens');
      await _authController.checkAuthStatus();
      _setStateIfActive(
        generation,
        const BootstrapState(status: BootstrapStatus.unauthenticated),
      );
      return;
    }

    // debugPrint('[BOOT] reissue_start');
    final reissueStopwatch = Stopwatch()..start();
    final newAccessToken = await _authService.reissueAccessToken();
    reissueStopwatch.stop();
    // debugPrint(
      // '[BOOT] reissue_end status=${newAccessToken == null ? 'fail' : 'success'} '
      // 'elapsedMs=${reissueStopwatch.elapsedMilliseconds}',
    // );
    if (_isStale(generation, stage: 'reissue_end')) return;

    if (newAccessToken == null) {
      // 재발급 실패 = refresh 만료 또는 서버 401. 보수적으로 로그아웃 처리.
      // 네트워크 일시 오류는 외부 타임아웃이 먼저 잡아서 retryable 로 빠진다.
      // debugPrint('[BOOT] route=unauthenticated reason=reissue_failed');
      await _authController.forceLogout();
      _setStateIfActive(
        generation,
        const BootstrapState(status: BootstrapStatus.unauthenticated),
      );
      return;
    }

    // 재발급 성공. 기존 인증 복원 루틴(userId/AppGroup/FCM) 재사용.
    // debugPrint('[BOOT] restoreSession_start');
    await _authController.checkAuthStatus();
    // debugPrint('[BOOT] restoreSession_end');
    if (_isStale(generation, stage: 'restoreSession_end')) return;

    // 메인 첫 화면(홈 + 캘린더) 데이터 선요청.
    // 두 요청은 독립적이고 서로 블로킹될 이유가 없어 병렬로 발행한다.
    // 각 개별 함수가 자기 예외/타임아웃을 내부에서 삼키므로 `Future.wait` 는
    // 항상 정상 종료되고, 부분 실패는 각 화면의 자체 로드 경로가 메운다.
    await Future.wait(<Future<void>>[
      _prefetchHomeData(generation),
      _prefetchCalendarData(generation),
    ]);
    if (_isStale(generation, stage: 'prefetch_end')) return;

    _setStateIfActive(
      generation,
      const BootstrapState(status: BootstrapStatus.authenticated),
    );
    // debugPrint('[BOOT] route=authenticated');
  }

  /// 현재 `generation` 이 최신이 아니면 true 를 반환한다(= 늦게 도착한 좀비 실행).
  ///
  /// 해당 stage 로그를 남겨 "어디에서 차단되었는지" 추적 가능하게 한다.
  bool _isStale(int generation, {required String stage}) {
    if (generation == _runGeneration) return false;
    // debugPrint(
      // '[BOOT] stage_aborted stage=$stage '
      // 'gen=$generation current=$_runGeneration',
    // );
    return true;
  }

  /// 현재 `generation` 이 최신일 때만 state 를 갱신한다.
  void _setStateIfActive(int generation, BootstrapState next) {
    if (generation != _runGeneration) {
      // debugPrint(
        // '[BOOT] state_write_ignored '
        // 'gen=$generation current=$_runGeneration target=${next.status.name}',
      // );
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
    // debugPrint('[BOOT] prefetch_home_start');
    final stopwatch = Stopwatch()..start();
    try {
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
        // debugPrint(
          // '[BOOT] prefetch_home_end status=stale '
          // 'elapsedMs=${stopwatch.elapsedMilliseconds} '
          // 'gen=$generation current=$_runGeneration',
        // );
        return;
      }
      ref.read(homePrefetchProvider.notifier).state = dto;
      stopwatch.stop();
      // debugPrint(
        // '[BOOT] prefetch_home_end status=success '
        // 'elapsedMs=${stopwatch.elapsedMilliseconds} '
        // 'schedules=${dto.schedules.length} folders=${dto.folders.length}',
      // );
    } on TimeoutException {
      stopwatch.stop();
      // debugPrint(
        // '[BOOT] prefetch_home_end status=timeout '
        // 'elapsedMs=${stopwatch.elapsedMilliseconds}',
      // );
    } catch (e) {
      stopwatch.stop();
      // debugPrint(
        // '[BOOT] prefetch_home_end status=fail error=$e '
        // 'elapsedMs=${stopwatch.elapsedMilliseconds}',
      // );
    }
  }

  /// 캘린더(현재월) 일정(`/page/schedules/search`) 선요청.
  /// 성공 시 `calendarPrefetchProvider` 에 `(month, events)` 를 주입해
  /// 이후 `CalendarController` 가 네트워크 재호출 없이 즉시 렌더되도록 한다.
  ///
  /// 홈 프리패치와 동일하게 개별 타임아웃(`_prefetchTimeout`) 과 부분 실패
  /// 허용 정책을 따르며, 이 메서드는 예외를 밖으로 던지지 않는다.
  Future<void> _prefetchCalendarData(int generation) async {
    // debugPrint('[BOOT] prefetch_calendar_start');
    final stopwatch = Stopwatch()..start();
    try {
      final now = DateTime.now();
      // 캘린더 화면이 처음 보여줄 월 = 현재 월. 1일 ~ 말일 구간을 조회한다.
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);
      final events = await _scheduleApiClient
          .searchSchedules(startDate: startDate, endDate: endDate)
          .timeout(_prefetchTimeout);
      // 좀비 응답이 이미 취소된 세션의 캐시를 오염시키지 못하도록 가드.
      if (generation != _runGeneration) {
        stopwatch.stop();
        // debugPrint(
          // '[BOOT] prefetch_calendar_end status=stale '
          // 'elapsedMs=${stopwatch.elapsedMilliseconds} '
          // 'gen=$generation current=$_runGeneration',
        // );
        return;
      }
      ref.read(calendarPrefetchProvider.notifier).state = CalendarPrefetchData(
        month: startDate,
        events: events,
      );
      stopwatch.stop();
      // debugPrint(
        // '[BOOT] prefetch_calendar_end status=success '
        // 'elapsedMs=${stopwatch.elapsedMilliseconds} '
        // 'events=${events.length}',
      // );
    } on TimeoutException {
      stopwatch.stop();
      // debugPrint(
        // '[BOOT] prefetch_calendar_end status=timeout '
        // 'elapsedMs=${stopwatch.elapsedMilliseconds}',
      // );
    } catch (e) {
      stopwatch.stop();
      // debugPrint(
        // '[BOOT] prefetch_calendar_end status=fail error=$e '
        // 'elapsedMs=${stopwatch.elapsedMilliseconds}',
      // );
    }
  }
}

/// 부트스트랩 Provider.
///
/// 실제 실행은 `main.dart` 의 `_initAuth` 에서 `run()` 을 호출해 트리거한다.
final bootstrapProvider = NotifierProvider<BootstrapController, BootstrapState>(
  BootstrapController.new,
);

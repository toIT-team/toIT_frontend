import 'package:flutter/material.dart';

/// 앱 전역 공통 스낵바 표시 헬퍼.
///
/// 시각 스타일은 `AppTheme.snackBarTheme`(플로팅·둥근 모서리·다크)를 따른다.
/// 이 헬퍼는 호출부 보일러플레이트를 없애고, 표시 동작(중복 제거·기본
/// 지속시간)을 한곳에서 관리하기 위한 단일 진입점이다.
void showAppSnackBar(
  BuildContext context,
  String message, {
  Duration duration = _defaultDuration,
}) {
  showAppSnackBarWith(
    ScaffoldMessenger.of(context),
    message,
    duration: duration,
  );
}

/// 비동기 작업 등으로 [ScaffoldMessengerState]를 미리 확보해 둔 경우 사용한다.
///
/// `await` 이후 `BuildContext` 사용이 위험한 상황에서, 작업 시작 전에 잡아둔
/// messenger로 안전하게 스낵바를 띄울 수 있다.
void showAppSnackBarWith(
  ScaffoldMessengerState messenger,
  String message, {
  Duration duration = _defaultDuration,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: duration));
}

/// 단일 스타일 기본 노출 시간.
const Duration _defaultDuration = Duration(seconds: 2);

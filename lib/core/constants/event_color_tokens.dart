import 'package:flutter/material.dart';

/// 일정 색상 토큰 (enum)
/// 프론트-백 공유: 백엔드에서 토큰 이름 전달 시 이 색상 사용
/// 사진 기준 10색만 enum 매핑
enum EventColorToken {
  pink200,
  orange200,
  yellow200,
  green200,
  pink100,
  blue300,
  blue400,
  purple500,
  grey200,
  grey100,
}

/// EventColorToken → Color 매핑 및 변환
class EventColorTokens {
  EventColorTokens._();

  static const Map<EventColorToken, Color> _tokenColors = {
    EventColorToken.pink200: Color(0xFFFFA2A4),
    EventColorToken.orange200: Color(0xFFFFC6A2),
    EventColorToken.yellow200: Color(0xFFFEEC88),
    EventColorToken.green200: Color(0xFFB6F394),
    EventColorToken.pink100: Color(0xFFFFB9DD),
    EventColorToken.blue300: Color(0xFFA2CAFF),
    EventColorToken.blue400: Color(0xFF99EDF7),
    EventColorToken.purple500: Color(0xFFC4A2FF),
    EventColorToken.grey200: Color(0xFFC2B7AD),
    EventColorToken.grey100: Color(0xFFDADADA),
  };

  /// enum → 백엔드 토큰 문자열 (camelCase)
  static const Map<EventColorToken, String> _tokenNames = {
    EventColorToken.pink200: 'pink200',
    EventColorToken.orange200: 'orange200',
    EventColorToken.yellow200: 'yellow200',
    EventColorToken.green200: 'green200',
    EventColorToken.pink100: 'pink100',
    EventColorToken.blue300: 'blue300',
    EventColorToken.blue400: 'blue400',
    EventColorToken.purple500: 'purple500',
    EventColorToken.grey200: 'grey200',
    EventColorToken.grey100: 'grey100',
  };

  static final Map<String, EventColorToken> _nameToToken = {
    for (final e in EventColorToken.values) _tokenNames[e]!: e,
    // 백엔드가 snake_case 값 반환 시 호환 후에 전부 카멜로 변경될 경우 삭제 예정
    'pink_200': EventColorToken.pink200,
    'orange_200': EventColorToken.orange200,
    'yellow_200': EventColorToken.yellow200,
    'green_200': EventColorToken.green200,
    'pink_100': EventColorToken.pink100,
    'blue_300': EventColorToken.blue300,
    'blue_400': EventColorToken.blue400,
    'purple_500': EventColorToken.purple500,
    'grey_200': EventColorToken.grey200,
    'grey_100': EventColorToken.grey100,
  };

  static const EventColorToken _default = EventColorToken.blue300;

  static Color get defaultColor => _tokenColors[_default]!;

  static Color of(EventColorToken token) =>
      _tokenColors[token] ?? _tokenColors[_default]!;

  static String toToken(EventColorToken token) => _tokenNames[token]!;

  /// 백엔드 문자열 → Color (camelCase 토큰 사용)
  static Color fromToken(String? tokenOrHex) {
    if (tokenOrHex == null || tokenOrHex.trim().isEmpty) {
      return defaultColor;
    }
    final key = tokenOrHex.trim();

    final token = _nameToToken[key];
    if (token != null) return of(token);

    final color = _tryParseHex(key);
    if (color != null) return color;

    return defaultColor;
  }

  static EventColorToken? tryParseFromColor(Color color) {
    final argb = color.toARGB32();
    for (final entry in _tokenColors.entries) {
      if (entry.value.toARGB32() == argb) return entry.key;
    }
    return null;
  }

  static String? toTokenString(Color color) {
    final token = tryParseFromColor(color);
    return token != null ? toToken(token) : null;
  }

  /// 색상 선택 UI용 (사진 순서)
  static const List<EventColorToken> pickerOrder = [
    EventColorToken.pink200,
    EventColorToken.orange200,
    EventColorToken.yellow200,
    EventColorToken.green200,
    EventColorToken.pink100,
    EventColorToken.blue300,
    EventColorToken.blue400,
    EventColorToken.purple500,
    EventColorToken.grey200,
    EventColorToken.grey100,
  ];

  static List<({EventColorToken token, Color color})> get pickerEntries =>
      pickerOrder.map((t) => (token: t, color: of(t))).toList();

  static Color? _tryParseHex(String hexStr) {
    try {
      var hex = hexStr.trim();
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length != 8) return null;
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }
}

extension EventColorTokenExtension on EventColorToken {
  Color get color => EventColorTokens.of(this);
}

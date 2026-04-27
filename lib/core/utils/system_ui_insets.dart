import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// 시스템(제스처/3버튼) 내비·홈 제스처 등 하단 인셋.
///
/// Android edge-to-edge에서 [MediaQueryData.padding] 하단이 0이어도
/// [viewPadding]에 잡힌 영역이 있으므로 둘의 최댓값을 쓴다.
/// 일부 기기(예: 갤럭시)에서는 제스처 영역이 [systemGestureInsets]로만
/// 노출될 수 있어 이를 함께 반영한다.
double systemBottomBarPadding(BuildContext context) {
  final m = MediaQuery.of(context);
  final baseInset = math.max(m.viewPadding.bottom, m.padding.bottom);
  return math.max(baseInset, m.systemGestureInsets.bottom);
}

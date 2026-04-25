import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// 시스템(제스처/3버튼) 내비·홈 제스처 등 하단 인셋.
///
/// Android edge-to-edge에서 [MediaQueryData.padding] 하단이 0이어도
/// [viewPadding]에 잡힌 영역이 있으므로 둘의 최댓값을 쓴다.
/// [CustomBottomNavBar]와 동일한 합의 방식.
double systemBottomBarPadding(BuildContext context) {
  final m = MediaQuery.of(context);
  return math.max(m.viewPadding.bottom, m.padding.bottom);
}

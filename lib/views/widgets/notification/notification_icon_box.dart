import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/dto/notifications_page_response_dto.dart';

/// 알림 유형별 아이콘을 담는 둥근 사각형 박스 (피그마: 흰 배경·얇은 테두리)
class NotificationIconBox extends StatelessWidget {
  const NotificationIconBox({super.key, required this.type});

  static const double _boxSize = 44;
  static const double _iconSize = 24;
  static const double _radius = 8;

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final path = switch (type) {
      NotificationType.schedule => AppAssets.searchResultEventIcon,
      NotificationType.feedbackReply => AppAssets.notificationFeedbackIcon,
      NotificationType.notice => AppAssets.notificationNoticeIcon,
    };

    return Container(
      width: _boxSize,
      height: _boxSize,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Center(
        child: SvgPicture.asset(
          path,
          width: _iconSize,
          height: _iconSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

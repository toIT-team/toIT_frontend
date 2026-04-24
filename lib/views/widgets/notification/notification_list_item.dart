import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/dto/notifications_page_response_dto.dart';
import '../common/app_divider.dart';
import 'notification_icon_box.dart';

/// 알림 목록 한 행 (아이콘 + 제목 + sentAt 부제)
class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.item,
    required this.showBottomDivider,
    required this.onTap,
  });

  final NotificationItemDto item;
  final bool showBottomDivider;
  final VoidCallback onTap;

  static const double _horizontalPad = 20;
  static const double _verticalPad = 14;
  static const double _gapIconText = 13;
  static const double _gapTitleSentAt = 4;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPad,
                _verticalPad,
                _horizontalPad,
                _verticalPad,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotificationIconBox(type: item.type),
                  const SizedBox(width: _gapIconText),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title.isEmpty ? '(제목 없음)' : item.title,
                          softWrap: true,
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: _gapTitleSentAt),
                        Text(
                          item.listSubtitleKo,
                          style: const TextStyle(
                            color: AppColors.gray600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showBottomDivider) const AppDivider(indent: 0, endIndent: 0),
          ],
        ),
      ),
    );
  }
}

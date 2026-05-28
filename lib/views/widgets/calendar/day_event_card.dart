import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/schedule_range_display_utils.dart';
import '../../../models/calendar/calendar_event.dart';
import '../../screens/event_detail_screen.dart';
import '../event/event_card_context_menu.dart';

/// 일정 카드 위젯 (바텀시트 내 사용)
class DayEventCard extends StatefulWidget {
  const DayEventCard({
    super.key,
    required this.event,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  final CalendarEvent event;

  /// 수정 탭 시 호출 (null이면 롱 프레스 메뉴 미표시)
  final VoidCallback? onEdit;

  /// 삭제 탭 시 호출 (null이면 롱 프레스 메뉴 미표시)
  final VoidCallback? onDelete;

  /// 공유 탭 시 호출 (null이면 메뉴에 공유 항목 미표시)
  final VoidCallback? onShare;

  @override
  State<DayEventCard> createState() => _DayEventCardState();
}

class _DayEventCardState extends State<DayEventCard> {
  static const _cardHorizontalMargin = 16.0;
  static const _cardVerticalMargin = 6.0;
  static const _cardBorderRadius = 16.0;
  static const _leftBarWidth = 4.0;
  static const _cardHorizontalPadding = 16.0;
  static const _cardVerticalPadding = 12.0;
  static const _cardMinHeight = 72.0;

  Offset _lastTouchPosition = Offset.zero;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasContextMenu = widget.onEdit != null && widget.onDelete != null;

    return Listener(
      onPointerDown: (event) {
        _lastTouchPosition = event.position;
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPressStart: hasContextMenu
            ? (_) => setState(() => _isPressed = true)
            : null,
        onLongPressEnd: hasContextMenu
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTap: () {
          setState(() => _isPressed = false);
          final schedulesId = int.tryParse(widget.event.id);
          if (schedulesId == null) return;

          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(schedulesId: schedulesId),
            ),
          );
        },
        onLongPress: hasContextMenu
            ? () {
                setState(() => _isPressed = false);
                _showContextMenu(context, _lastTouchPosition);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(
            horizontal: _cardHorizontalMargin,
            vertical: _cardVerticalMargin,
          ),
          constraints: const BoxConstraints(minHeight: _cardMinHeight),
          decoration: BoxDecoration(
            color: _isPressed ? AppColors.neutral50 : Colors.white,
            borderRadius: BorderRadius.circular(_cardBorderRadius),
            border: Border.all(color: AppColors.neutral100),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  width: _leftBarWidth,
                  decoration: BoxDecoration(
                    color: widget.event.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(_cardBorderRadius),
                      bottomLeft: Radius.circular(_cardBorderRadius),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _cardHorizontalPadding,
                      vertical: _cardVerticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ScheduleRangeDisplayUtils.formatEventRangeLine(
                            widget.event,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset touchPosition) {
    showEventCardContextMenu(
      context: context,
      touchPosition: touchPosition,
      onEdit: widget.onEdit!,
      onDelete: widget.onDelete!,
      onShare: widget.onShare,
    );
  }

}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _isPressed ? Colors.grey[300]! : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.event.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          color: AppColors.gray900,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTimeText(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
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

  /// 시간 텍스트 생성
  String _getTimeText() {
    if (!widget.event.timeSetting) {
      return '하루 종일';
    }

    final startTime = _formatTime(widget.event.startTime);
    final endTime = _formatTime(widget.event.endTime);

    if (startTime != null && endTime != null) {
      return '$startTime - $endTime';
    } else if (startTime != null) {
      return startTime;
    }

    return '하루 종일';
  }

  /// 시간 포맷 (24시간 -> 오전/오후)
  String? _formatTime(String? time) {
    if (time == null) return null;

    final parts = time.split(':');
    if (parts.length != 2) return time;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$period $displayHour:$minute';
  }
}

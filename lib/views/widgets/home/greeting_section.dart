import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_assets.dart';
import '../../../models/home/schedule.dart';
import '../../screens/event_detail_screen.dart';
import '../../screens/event_form_screen.dart';
import 'schedule_card.dart';

/// 인사말 + 일정 카드 영역
class GreetingSection extends ConsumerWidget {
  final String userName;
  final int todayScheduleCount;
  final List<Schedule> schedules;

  const GreetingSection({
    super.key,
    required this.userName,
    required this.todayScheduleCount,
    required this.schedules,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSchedules = schedules.isNotEmpty;
    final greetingText = hasSchedules
        ? '$userName님 오늘 일정이\n$todayScheduleCount개 있습니다 ›'
        : '$userName님 오늘 일정을\n추가해보세요';
    final calendarImagePath = hasSchedules
        ? AppAssets.calendarIcon
        : AppAssets.calendarIcon2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                greetingText,
                style: const TextStyle(
                  color: AppColors.gray900,
                  fontSize: 24,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.45,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Image.asset(calendarImagePath, width: 88, height: 88),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (hasSchedules)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _buildScheduleCards(context, ref)),
          )
        else
          SizedBox(
            width: 189,
            height: 111,
            child: ScheduleCard(
              title: '오늘의 일정',
              subtitle: _formatTodayKoreanDate(),
              trailingText: null,
              accentColor: AppColors.gray100,
              showAddAction: true,
              onAddTap: () => _openAddSchedule(context, ref),
            ),
          ),
      ],
    );
  }

  Future<void> _openAddSchedule(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (_) => EventFormScreen(initialDate: DateTime.now()),
      ),
    );
    if (!context.mounted || result == null) return;
    await ref.read(homeProvider.notifier).refresh(silent: true);
  }

  List<Widget> _buildScheduleCards(BuildContext context, WidgetRef ref) {
    final widgets = <Widget>[];
    for (int i = 0; i < schedules.length; i++) {
      final s = schedules[i];
      widgets.add(
        SizedBox(
          width: 189,
          height: 111,
          child: _ScheduleCardTapAnimation(
            onTap: s.schedulesId > 0
                ? () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            EventDetailScreen(schedulesId: s.schedulesId),
                      ),
                    );
                    if (!context.mounted) return;
                    await ref.read(homeProvider.notifier).refresh(silent: true);
                  }
                : null,
            child: ScheduleCard(
              title: s.title,
              subtitle: s.timeRangeText,
              trailingText: s.scheduleTime,
              accentColor: s.accentColor,
              showAddAction: false,
              onAddTap: null,
            ),
          ),
        ),
      );
      if (i != schedules.length - 1) {
        widgets.add(const SizedBox(width: AppSpacing.xs));
      }
    }
    return widgets;
  }

  String _formatTodayKoreanDate() {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final now = DateTime.now();
    final weekday = weekdays[now.weekday - 1];
    return '${now.month}월${now.day}일($weekday)';
  }
}

class _ScheduleCardTapAnimation extends StatefulWidget {
  const _ScheduleCardTapAnimation({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_ScheduleCardTapAnimation> createState() =>
      _ScheduleCardTapAnimationState();
}

class _ScheduleCardTapAnimationState extends State<_ScheduleCardTapAnimation> {
  bool isPressed = false;

  void setPressed(bool nextValue) {
    if (isPressed == nextValue) return;
    setState(() {
      isPressed = nextValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      scale: isPressed ? 0.94 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: setPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}

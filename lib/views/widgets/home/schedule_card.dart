import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 일정 카드 위젯
class ScheduleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailingText;
  final Color accentColor;
  final bool showAddAction;
  final VoidCallback? onAddTap;

  const ScheduleCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailingText,
    required this.accentColor,
    this.showAddAction = false,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasTrailingText = trailingText != null && trailingText!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 41,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                        letterSpacing: -0.45,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: constraints.maxWidth,
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              subtitle,
                              softWrap: false,
                              style: const TextStyle(
                                color: AppColors.gray600,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasTrailingText) ...[
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                trailingText!,
                style: const TextStyle(
                  color: AppColors.gray600,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  letterSpacing: -0.35,
                ),
              ),
            ),
          ] else if (showAddAction) ...[
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: _ScheduleAddActionButton(onTap: onAddTap),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleAddActionButton extends StatefulWidget {
  const _ScheduleAddActionButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  State<_ScheduleAddActionButton> createState() =>
      _ScheduleAddActionButtonState();
}

class _ScheduleAddActionButtonState extends State<_ScheduleAddActionButton> {
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
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: setPressed,
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isPressed
                  ? AppColors.neutral100.withOpacity(0.55)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '추가',
                  style: TextStyle(
                    color: AppColors.gray600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: -0.35,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.add, size: 16, color: AppColors.gray600),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

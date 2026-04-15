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
              child: GestureDetector(
                onTap: onAddTap,
                behavior: HitTestBehavior.opaque,
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
          ],
        ],
      ),
    );
  }
}

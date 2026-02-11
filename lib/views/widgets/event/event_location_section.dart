import 'package:flutter/material.dart';

import '../common/tappable_row.dart';

/// 위치 섹션
class EventLocationSection extends StatelessWidget {
  const EventLocationSection({
    super.key,
    this.location,
    this.isEditable = false,
    this.onTap,
  });

  final String? location;
  final bool isEditable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasLocation = location != null && location!.isNotEmpty;

    return TappableRow(
      title: hasLocation ? location! : '위치',
      titleColor: hasLocation ? Colors.black : Colors.grey,
      onTap: onTap,
      showArrow: false,
    );
  }
}

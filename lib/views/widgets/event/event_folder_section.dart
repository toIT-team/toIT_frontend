import 'package:flutter/material.dart';

import '../common/tappable_row.dart';

/// 보관함(폴더) 섹션
class EventFolderSection extends StatelessWidget {
  const EventFolderSection({
    super.key,
    required this.folderName,
    this.isEditable = false,
    this.onTap,
  });

  final String folderName;
  final bool isEditable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TappableRow(
      title: folderName,
      onTap: onTap,
      showArrow: true,
    );
  }
}

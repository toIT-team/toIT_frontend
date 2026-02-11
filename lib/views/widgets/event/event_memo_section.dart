import 'package:flutter/material.dart';

import '../../../core/constants/setting_layout_tokens.dart';

/// 메모 섹션
class EventMemoSection extends StatelessWidget {
  const EventMemoSection({
    super.key,
    this.memo,
    this.memoDate,
    this.memoController,
    this.isEditable = false,
    this.onTap,
    this.onChanged,
  });

  final String? memo;
  final String? memoDate;

  /// 편집 모드 시 사용할 TextEditingController (제공 시 TextField 표시)
  final TextEditingController? memoController;

  final bool isEditable;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasMemo = memo != null && memo!.isNotEmpty;
    final useTextField =
        isEditable && memoController != null && onChanged != null;

    if (useTextField) {
      return TextField(
        controller: memoController,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: SettingLayout1Tokens.fontSize,
        ),
        maxLines: 3,
        minLines: 1,
        decoration: const InputDecoration(
          hintText: '메모 추가',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: SettingLayout1Tokens.fontSize,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      );
    }

    if (isEditable) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: _buildReadOnlyContent(hasMemo),
      );
    }

    return _buildReadOnlyContent(hasMemo);
  }

  Widget _buildReadOnlyContent(bool hasMemo) {
    return Row(
      children: [
        Expanded(
          child: Text(
            hasMemo ? memo! : '메모 추가',
            style: TextStyle(
              fontSize: SettingLayout1Tokens.fontSize,
              color: hasMemo ? Colors.black : Colors.grey,
            ),
          ),
        ),
        if (hasMemo && memoDate != null)
          Text(
            memoDate!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
      ],
    );
  }
}

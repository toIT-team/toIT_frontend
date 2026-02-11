import 'package:flutter/material.dart';

/// 메모 섹션
class EventMemoSection extends StatelessWidget {
  const EventMemoSection({
    super.key,
    this.memo,
    this.memoDate,
    this.isEditable = false,
    this.onTap,
    this.onChanged,
  });

  final String? memo;
  final String? memoDate;
  final bool isEditable;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasMemo = memo != null && memo!.isNotEmpty;

    // 편집 모드일 때 TextField 사용
    if (isEditable) {
      return _buildEditableContent(hasMemo);
    }

    // 읽기 모드
    return _buildReadOnlyContent(hasMemo);
  }

  Widget _buildReadOnlyContent(bool hasMemo) {
    return Row(
      children: [
        Expanded(
          child: Text(
            hasMemo ? memo! : '메모 추가',
            style: TextStyle(
              fontSize: 16,
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

  Widget _buildEditableContent(bool hasMemo) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasMemo ? memo! : '메모 추가',
              style: TextStyle(
                fontSize: 16,
                color: hasMemo ? Colors.black : Colors.grey,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

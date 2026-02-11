import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/alarm_constants.dart';
import '../../../core/constants/app_color_tokens.dart';

/// 알림 옵션 선택 바텀시트 (사진 디자인 기준)
///
/// - 상단 회색 드래그 핸들
/// - 둥근 상단 모서리
/// - 선택: 파란색 배경 원형 + 흰색 체크
/// - 미선택: 회색 테두리 원형
/// - 직접 설정: 검은색 + 아이콘
class AlarmPickerSheet extends StatelessWidget {
  const AlarmPickerSheet({
    super.key,
    required this.currentMinutes,
    required this.onOptionSelected,
    required this.onCustomSettingTap,
  });

  final int? currentMinutes;
  final ValueChanged<int> onOptionSelected;
  final VoidCallback onCustomSettingTap;

  @override
  Widget build(BuildContext context) {
    final displayMinutes = currentMinutes ?? 0;
    final isCustomSelected = currentMinutes != null &&
        !AlarmUtils.predefinedMinutes.contains(currentMinutes);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ...AlarmUtils.predefinedOptions.map((option) {
            final isSelected =
                !isCustomSelected && displayMinutes == option.$1;
            return _AlarmOptionTile(
              label: option.$2,
              isSelected: isSelected,
              isCustomOption: false,
              onTap: () {
                onOptionSelected(option.$1);
                Navigator.pop(context);
              },
            );
          }),
          _AlarmOptionTile(
            label: '직접 설정',
            isSelected: isCustomSelected,
            isCustomOption: true,
            onTap: () {
              Navigator.pop(context);
              onCustomSettingTap();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AlarmOptionTile extends StatelessWidget {
  const _AlarmOptionTile({
    required this.label,
    required this.isSelected,
    required this.isCustomOption,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isCustomOption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
            _buildTrailingIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingIcon() {
    if (isCustomOption) {
      return Icon(
        isSelected ? Icons.check_circle : Icons.add,
        color: isSelected ? AppColorTokens.blue500 : Colors.black87,
        size: 24,
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColorTokens.blue500 : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColorTokens.blue500 : Colors.grey[400]!,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }
}

/// 알림 직접 설정 바텀시트
class AlarmCustomPickerSheet extends StatefulWidget {
  const AlarmCustomPickerSheet({
    super.key,
    required this.initialValue,
    required this.initialUnit,
    required this.onConfirm,
  });

  final int initialValue;
  final AlarmUnit initialUnit;
  final ValueChanged<int> onConfirm;

  @override
  State<AlarmCustomPickerSheet> createState() => _AlarmCustomPickerSheetState();
}

class _AlarmCustomPickerSheetState extends State<AlarmCustomPickerSheet> {
  late int _value;
  late AlarmUnit _unit;
  late FixedExtentScrollController _valueController;
  late FixedExtentScrollController _unitController;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _unit = widget.initialUnit;
    _valueController = FixedExtentScrollController(
      initialItem: _value.clamp(0, 99),
    );
    _unitController = FixedExtentScrollController(
      initialItem: _unit.index,
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWheelPicker(
                  controller: _valueController,
                  itemCount: 100,
                  selectedIndex: _value,
                  builder: (_, i) => Text('$i'),
                  onSelected: (i) => setState(() => _value = i.clamp(0, 99)),
                ),
                const SizedBox(width: 16),
                _buildWheelPicker(
                  controller: _unitController,
                  itemCount: AlarmUnit.values.length,
                  selectedIndex: _unit.index,
                  builder: (_, i) => Text(AlarmUnit.values[i].label),
                  onSelected: (i) => setState(() => _unit = AlarmUnit.values[i]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColorTokens.blue500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final minutes = AlarmUtils.toMinutes(_value, _unit);
                  widget.onConfirm(minutes);
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int selectedIndex,
    required Widget Function(BuildContext, int) builder,
    required ValueChanged<int> onSelected,
  }) {
    return SizedBox(
      width: 80,
      height: 140,
      child: CupertinoPicker.builder(
        scrollController: controller,
        itemExtent: 40,
        childCount: itemCount,
        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
          background: Colors.transparent,
        ),
        onSelectedItemChanged: onSelected,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Center(
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: isSelected ? 24 : 18,
                color: isSelected ? Colors.black : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: builder(context, index),
            ),
          );
        },
      ),
    );
  }
}

/// 바텀시트 공통 스타일
class BottomSheetStyle {
  BottomSheetStyle._();

  static const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool showDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: shape,
      showDragHandle: showDragHandle,
      builder: (context) => child,
    );
  }
}

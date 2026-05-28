import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

/// 검색 화면·바텀시트 등에서 공통으로 쓰는 둥근 검색 입력 필드.
///
/// [SearchIcon.png]·[DeleteIcon.png]는 [InputDecoration] 밖 [Row]에 두어,
/// 접미·접두가 바뀔 때마다 장식이 갱신되며 한글 IME 조합이 끊기는 문제를
/// 피한다.
class SearchFieldWidget extends StatefulWidget {
  const SearchFieldWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.autofocus = false,
    this.height = 58,
  });

  /// 비어 있으면 우측 지우기는 숨긴다.
  final TextEditingController? controller;

  final ValueChanged<String>? onChanged;
  final bool autofocus;

  /// 필드 전체(배경 포함) 높이
  final double height;

  static const Color _fillColor = Color(0xFFF2F3F5);
  static const double _radius = 14;

  /// 우측 지우기 탭 영역 (유무와 관계없이 폭 고정 → 레이아웃 점프 완화)
  static const double _trailingSlotWidth = 44;

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(SearchFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerTick);
      widget.controller?.addListener(_onControllerTick);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller?.text.isNotEmpty ?? false;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: SearchFieldWidget._fillColor,
        borderRadius: BorderRadius.circular(SearchFieldWidget._radius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 6),
            child: _SearchPrefixIcon(),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              autofocus: widget.autofocus,
              // 모바일 네이티브는 기본 onTapOutside가 터치에서 포커스를
              // 풀지 않음(EditableTextTapOutsideIntent). 갤럭시 등에서 바깥
              // 탭 시 키보드 내리기 위해 명시한다.
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '검색',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8E95A2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 18,
                ),
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
              cursorColor: AppColors.gray900,
            ),
          ),
          SizedBox(
            width: SearchFieldWidget._trailingSlotWidth,
            child: IgnorePointer(
              ignoring: !hasText,
              child: Opacity(
                opacity: hasText ? 1 : 0,
                child: GestureDetector(
                  onTap: () {
                    widget.controller?.clear();
                    widget.onChanged?.call('');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Center(
                    child: _SearchClearIcon(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPrefixIcon extends StatelessWidget {
  const _SearchPrefixIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.searchIcon,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }
}

class _SearchClearIcon extends StatelessWidget {
  const _SearchClearIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Image.asset(
        AppAssets.deleteIcon,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
      ),
    );
  }
}

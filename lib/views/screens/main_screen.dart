import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/common/add_action_button.dart';
import '../widgets/common/add_context_menu.dart';
import '../widgets/common/glass_nav_bar.dart';
import 'calendar_screen.dart';
import 'event_form_screen.dart';

/// 현재 선택된 탭 인덱스 Provider
final currentTabProvider = StateProvider<int>((ref) => 0);

/// 메인 화면 (하단 네비게이션 + FAB 통합)
///
/// IndexedStack으로 탭 화면을 관리하고,
/// 하단에 글래스모피즘 네비게이션 바와 + FAB 버튼을 배치한다.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  /// + 버튼 위치 계산용 GlobalKey
  final _fabKey = GlobalKey();

  /// 하단 바 높이 (네비게이션 바 + SafeArea 하단 여백)
  static const _bottomBarHeight = 56.0;
  static const _bottomBarPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // 탭 화면들
          Padding(
            padding: EdgeInsets.only(
              bottom: _bottomBarHeight + _bottomBarPadding * 2 + bottomPadding,
            ),
            child: IndexedStack(
              index: currentTab,
              children: const [_HomePlaceholder(), CalendarScreen()],
            ),
          ),
          // 하단 네비게이션 영역
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBarArea(
              fabKey: _fabKey,
              currentTab: currentTab,
              onTabChanged: _handleTabChanged,
              onFabTap: _handleFabTap,
              bottomPadding: bottomPadding,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTabChanged(int index) {
    ref.read(currentTabProvider.notifier).state = index;
  }

  void _handleFabTap() {
    showAddContextMenu(
      context: context,
      anchorKey: _fabKey,
      items: [
        ContextMenuItem(
          icon: Icons.calendar_today_outlined,
          label: '일정 추가',
          onTap: _navigateToEventForm,
        ),
      ],
    );
  }

  void _navigateToEventForm() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const EventFormScreen()))
        .then((result) {
          if (result == null) return;
          ref.read(currentTabProvider.notifier).state = 1;
        });
  }
}

/// 하단 바 영역 (글래스 네비게이션 바 + FAB)
class _BottomBarArea extends StatelessWidget {
  const _BottomBarArea({
    required this.fabKey,
    required this.currentTab,
    required this.onTabChanged,
    required this.onFabTap,
    required this.bottomPadding,
  });

  final GlobalKey fabKey;
  final int currentTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onFabTap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPadding + 16),
      child: Row(
        children: [
          // 글래스모피즘 네비게이션 바 (좌측 ~70%)
          Expanded(
            child: GlassNavBar(currentIndex: currentTab, onTap: onTabChanged),
          ),
          const SizedBox(width: 12),
          // + FAB 버튼 (우측)
          AddActionButton(key: fabKey, onTap: onFabTap),
        ],
      ),
    );
  }
}

/// 홈 화면 Placeholder
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: 메뉴 열기
          },
        ),
        title: const Text('홈'),
      ),
      body: const Center(
        child: Text('홈 화면', style: TextStyle(fontSize: 16, color: Colors.grey)),
      ),
    );
  }
}

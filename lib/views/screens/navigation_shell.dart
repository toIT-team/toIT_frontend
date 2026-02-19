import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/home_controller.dart';
import '../widgets/common/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'save_link_screen.dart';
import 'save_note_screen.dart';

/// 현재 선택된 탭 인덱스 Provider
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

/// 네비게이션 쉘 (하단 네비바 + 화면 전환 관리)
class NavigationShell extends ConsumerWidget {
  const NavigationShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [HomeScreen(), CalendarScreen(), _ChatPlaceholder()],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            ref.read(homeProvider.notifier).refresh();
          }
          ref.read(currentTabIndexProvider.notifier).state = index;
        },
        onAddMenuTap: (menuIndex) {
          switch (menuIndex) {
            case 0:
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SaveLinkScreen()));
            case 1:
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SaveNoteScreen()));
          }
        },
      ),
      extendBody: true,
    );
  }
}

/// 채팅 화면 플레이스홀더
class _ChatPlaceholder extends StatelessWidget {
  const _ChatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '채팅 화면\n(준비 중)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}

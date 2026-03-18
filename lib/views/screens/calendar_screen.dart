import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_screen.dart';
import '../widgets/calendar/calendar_widget.dart';
import '../widgets/home/home_app_bar.dart';

/// 캘린더 화면
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: HomeAppBar(
          title: '캘린더',
          onSearchPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SearchScreen(),
              ),
            );
          },
        ),
      ),
      body: const CalendarWidget(),
    );
  }
}

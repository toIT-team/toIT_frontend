import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poj_todo/views/widgets/common/app_alert_dialog.dart';

void main() {
  testWidgets('showAppAlertDialog shows title, message, confirm', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => showAppAlertDialog(
                  context,
                  message: 'test message',
                ),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('알림'), findsOneWidget);
    expect(find.text('test message'), findsOneWidget);
    expect(find.text('확인'), findsOneWidget);
  });
}

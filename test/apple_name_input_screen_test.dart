import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toit/views/screens/apple_name_input_screen.dart';

void main() {
  testWidgets('AppleNameInputScreen submits entered nickname', (tester) async {
    String? submittedNickname;

    await tester.pumpWidget(
      MaterialApp(
        home: AppleNameInputScreen(
          onSubmit: (nickname) {
            submittedNickname = nickname;
          },
        ),
      ),
    );

    expect(find.text('닉네임을 입력해 주세요'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isFalse,
    );

    await tester.enterText(find.byType(TextField), '새사용자');
    await tester.pump();

    expect(find.text('4/10'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isTrue,
    );

    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(submittedNickname, '새사용자');
  });
}

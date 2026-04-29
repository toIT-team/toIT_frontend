import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toit/views/widgets/event/event_folder_section.dart';

void main() {
  testWidgets('편집 모드·보관함 있으면 닫기 아이콘 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EventFolderSection(
            folderName: '기본 보관함',
            isEditable: true,
            onTap: null,
            onClearFolderTap: null,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('편집 모드·보관함 없으면 추가 아이콘 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EventFolderSection(
            folderName: null,
            isEditable: true,
            onTap: null,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });
}

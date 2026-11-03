import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack/screens/add_task_screen.dart';
import 'package:studytrack/theme/app_theme.dart';

void main() {
  testWidgets(
    'save and cancel remain reachable with a small keyboard viewport',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AddTaskScreen()),
      );
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Save study task'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save study task'), findsOneWidget);
      expect(
        tester.getRect(find.text('Save study task')).bottom,
        lessThanOrEqualTo(640 - 280),
      );
      final exception = tester.takeException();
      expect(exception, isNull);
    },
  );
}

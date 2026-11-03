import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack/theme/app_theme.dart';
import 'package:studytrack/widgets/empty_state.dart';

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('empty state uses readable text in ${theme.brightness} mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: EmptyState(
              title: 'No tasks',
              message: 'Add a task to begin.',
            ),
          ),
        ),
      );

      final message = tester.widget<Text>(find.text('Add a task to begin.'));
      expect(message.style?.color, theme.colorScheme.onSurfaceVariant);
    });
  }
}

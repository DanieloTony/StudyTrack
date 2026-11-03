import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack/theme/app_theme.dart';
import 'package:studytrack/widgets/glass_surface.dart';

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets(
      'glass surface renders content and blur in ${theme.brightness} mode',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: GlassSurface(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const Text('Readable content'),
              ),
            ),
          ),
        );

        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(find.text('Readable content'), findsOneWidget);
      },
    );
  }
}

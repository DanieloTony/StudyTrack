import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:studytrack/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  testWidgets('StudyTrack app starts successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudyTrackApp());

    // Allow the app to render and its initial tasks to load.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(StudyTrackApp), findsOneWidget);
  });

  testWidgets('bottom navigation changes destinations and theme', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudyTrackApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Plan a study task'), findsOneWidget);
    var navigationRect = tester.getRect(
      find.byKey(const ValueKey('main-navigation')),
    );
    var actionRect = tester.getRect(find.byType(FloatingActionButton));
    expect(actionRect.bottom, lessThanOrEqualTo(navigationRect.top));

    await tester.tap(find.text('Settings').last);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Your activity'), findsOneWidget);
    navigationRect = tester.getRect(
      find.byKey(const ValueKey('main-navigation')),
    );
    expect(
      tester.getRect(find.text('Your activity')).bottom,
      lessThanOrEqualTo(navigationRect.top),
    );
    final settingsPadding = tester
        .widget<ListView>(find.byType(ListView).last)
        .padding!
        .resolve(TextDirection.ltr);
    expect(settingsPadding.bottom, 112);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.tap(find.text('Tasks'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('My tasks'), findsOneWidget);
    navigationRect = tester.getRect(
      find.byKey(const ValueKey('main-navigation')),
    );
    actionRect = tester.getRect(find.byType(FloatingActionButton));
    expect(actionRect.bottom, lessThanOrEqualTo(navigationRect.top));
    expect(tester.takeException(), isNull);
  });
}

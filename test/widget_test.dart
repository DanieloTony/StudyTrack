
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
}

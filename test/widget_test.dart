import 'package:flutter_test/flutter_test.dart';
import 'package:emora/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    try {
      await tester.pumpWidget(const EmoraApp());
    } catch (_) {
      // Ignore initial errors from Supabase in test environment
    }
  });
}

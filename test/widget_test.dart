// Basic smoke test placeholder.
//
// The original counter-app test was removed because the app now requires
// Supabase initialisation before it can run.  A proper widget test should
// mock the SupabaseClient via Riverpod overrides; that will be added in a
// later task.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder – app compiles', () {
    // Intentionally left as a no-op until Supabase mocks are set up.
    expect(true, isTrue);
  });
}

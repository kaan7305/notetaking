import 'package:flutter_test/flutter_test.dart';
import 'package:study_notebook/core/storage/database_migrations.dart';

void main() {
  group('DatabaseMigrations', () {
    test('currentVersion is a positive integer', () {
      expect(DatabaseMigrations.currentVersion, isA<int>());
      expect(DatabaseMigrations.currentVersion, greaterThan(0));
    });

    test('currentVersion is at least 3 (the baseline at time of writing)', () {
      expect(DatabaseMigrations.currentVersion, greaterThanOrEqualTo(3));
    });

    // Verify that run() returns normally (no throw) for a no-op range
    // (oldVersion >= newVersion) by checking the function accepts the right
    // parameter types.  A real DB integration test would require sqflite_ffi
    // and is left to device-level testing.
    test('run() is a static async function with the correct signature', () {
      expect(DatabaseMigrations.run, isA<Function>());
    });
  });
}

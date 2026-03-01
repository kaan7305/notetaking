import 'package:flutter_test/flutter_test.dart';
import 'package:study_notebook/core/models/pen_style.dart';

void main() {
  group('PenStyleConfig', () {
    test('every PenStyle has a config entry', () {
      for (final style in PenStyle.values) {
        expect(PenStyleConfig.configs.containsKey(style), true,
            reason: '${style.name} should have a config');
      }
    });

    test('standard pen has expected defaults', () {
      final config = PenStyleConfig.forStyle(PenStyle.standard);
      expect(config.thinning, 0.5);
      expect(config.smoothing, 0.5);
      expect(config.streamline, 0.5);
      expect(config.defaultWidth, 2.0);
      expect(config.taperStart, true);
      expect(config.taperEnd, true);
    });

    test('marker has zero thinning and no taper', () {
      final config = PenStyleConfig.forStyle(PenStyle.marker);
      expect(config.thinning, 0.0);
      expect(config.taperStart, false);
      expect(config.taperEnd, false);
      expect(config.defaultWidth, 6.0);
    });

    test('calligraphy has high thinning', () {
      final config = PenStyleConfig.forStyle(PenStyle.calligraphy);
      expect(config.thinning, greaterThan(0.7));
      expect(config.defaultWidth, 3.0);
    });

    test('fountain has high smoothing', () {
      final config = PenStyleConfig.forStyle(PenStyle.fountain);
      expect(config.smoothing, greaterThan(0.7));
    });

    test('fine liner has zero thinning and thin default', () {
      final config = PenStyleConfig.forStyle(PenStyle.fineLiner);
      expect(config.thinning, 0.0);
      expect(config.defaultWidth, 1.0);
      expect(config.taperStart, false);
    });

    test('pencil has low smoothing and streamline', () {
      final config = PenStyleConfig.forStyle(PenStyle.pencil);
      expect(config.smoothing, lessThan(0.3));
      expect(config.streamline, lessThan(0.3));
    });

    test('forStyle falls back to standard for unknown', () {
      // All enum values should be covered, but verify forStyle works
      final config = PenStyleConfig.forStyle(PenStyle.standard);
      expect(config.displayName, 'Standard');
    });

    test('all configs have non-empty display names', () {
      for (final entry in PenStyleConfig.configs.entries) {
        expect(entry.value.displayName.isNotEmpty, true,
            reason: '${entry.key.name} should have a display name');
      }
    });
  });
}

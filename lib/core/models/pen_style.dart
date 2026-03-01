/// Defines the available pen rendering styles and their perfect_freehand configs.
enum PenStyle {
  standard,
  calligraphy,
  fountain,
  marker,
  fineLiner,
  pencil,
}

/// Configuration for how a pen style renders via perfect_freehand.
class PenStyleConfig {
  final PenStyle style;
  final String displayName;
  final double thinning;
  final double smoothing;
  final double streamline;
  final double defaultWidth;
  final bool taperStart;
  final bool taperEnd;

  const PenStyleConfig({
    required this.style,
    required this.displayName,
    required this.thinning,
    required this.smoothing,
    required this.streamline,
    required this.defaultWidth,
    this.taperStart = true,
    this.taperEnd = true,
  });

  static const Map<PenStyle, PenStyleConfig> configs = {
    PenStyle.standard: PenStyleConfig(
      style: PenStyle.standard,
      displayName: 'Standard',
      thinning: 0.5,
      smoothing: 0.5,
      streamline: 0.5,
      defaultWidth: 2.0,
    ),
    PenStyle.calligraphy: PenStyleConfig(
      style: PenStyle.calligraphy,
      displayName: 'Calligraphy',
      thinning: 0.9,
      smoothing: 0.3,
      streamline: 0.3,
      defaultWidth: 3.0,
    ),
    PenStyle.fountain: PenStyleConfig(
      style: PenStyle.fountain,
      displayName: 'Fountain',
      thinning: 0.6,
      smoothing: 0.8,
      streamline: 0.7,
      defaultWidth: 2.5,
    ),
    PenStyle.marker: PenStyleConfig(
      style: PenStyle.marker,
      displayName: 'Marker',
      thinning: 0.0,
      smoothing: 0.5,
      streamline: 0.5,
      defaultWidth: 6.0,
      taperStart: false,
      taperEnd: false,
    ),
    PenStyle.fineLiner: PenStyleConfig(
      style: PenStyle.fineLiner,
      displayName: 'Fine Liner',
      thinning: 0.0,
      smoothing: 0.4,
      streamline: 0.6,
      defaultWidth: 1.0,
      taperStart: false,
      taperEnd: false,
    ),
    PenStyle.pencil: PenStyleConfig(
      style: PenStyle.pencil,
      displayName: 'Pencil',
      thinning: 0.3,
      smoothing: 0.2,
      streamline: 0.2,
      defaultWidth: 1.5,
    ),
  };

  static PenStyleConfig forStyle(PenStyle style) =>
      configs[style] ?? configs[PenStyle.standard]!;
}

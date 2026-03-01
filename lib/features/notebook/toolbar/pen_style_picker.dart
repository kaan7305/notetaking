import 'package:flutter/material.dart';

import 'package:study_notebook/core/models/models.dart';

/// A bottom sheet that lets the user choose a pen rendering style.
class PenStylePicker extends StatelessWidget {
  final PenStyle currentStyle;
  final ValueChanged<PenStyle> onStyleSelected;

  const PenStylePicker({
    super.key,
    required this.currentStyle,
    required this.onStyleSelected,
  });

  static const _icons = <PenStyle, IconData>{
    PenStyle.standard: Icons.edit,
    PenStyle.calligraphy: Icons.brush,
    PenStyle.fountain: Icons.create,
    PenStyle.marker: Icons.format_paint,
    PenStyle.fineLiner: Icons.drive_file_rename_outline,
    PenStyle.pencil: Icons.mode_edit_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pen Style',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: PenStyle.values.map((style) {
              final config = PenStyleConfig.forStyle(style);
              final isSelected = style == currentStyle;
              return GestureDetector(
                onTap: () => onStyleSelected(style),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withValues(alpha: 0.1)
                        : null,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_icons[style] ?? Icons.edit, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        config.displayName,
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:study_notebook/app/colors.dart';

/// The four filter tabs shown at the top of the library content area.
enum LibraryTab {
  allNotes,
  recents,
  favorites,
  unfiled;

  /// Human-readable label for each tab.
  String get label {
    switch (this) {
      case LibraryTab.allNotes:
        return 'All Notes';
      case LibraryTab.recents:
        return 'Recents';
      case LibraryTab.favorites:
        return 'Favorites';
      case LibraryTab.unfiled:
        return 'Unfiled';
    }
  }
}

/// A custom horizontal tab bar matching the Notability library look.
///
/// Each tab is a simple text button; the active tab is highlighted with
/// [AppColors.primary] text and a bottom underline.
class LibraryTabs extends StatelessWidget {
  const LibraryTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  final LibraryTab activeTab;
  final ValueChanged<LibraryTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: LibraryTab.values.map((tab) {
          final isActive = tab == activeTab;
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? AppColors.primary
                          : Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  // Underline indicator
                  Container(
                    height: 2,
                    width: tab.label.length * 7.5,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

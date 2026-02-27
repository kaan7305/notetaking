import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/course_provider.dart';
import 'package:study_notebook/core/providers/notebook_provider.dart';

/// Holds the current search query entered in the library sidebar.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filters courses by the current search query (case-insensitive name match).
final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final coursesAsync = ref.watch(courseProvider);

  if (query.isEmpty) return coursesAsync;

  return coursesAsync.whenData(
    (courses) => courses
        .where((c) => c.name.toLowerCase().contains(query))
        .toList(),
  );
});

/// Filters all notebooks by the current search query (case-insensitive title
/// match).
final filteredNotebooksProvider =
    Provider<AsyncValue<List<Notebook>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final notebooksAsync = ref.watch(allNotebooksProvider);

  if (query.isEmpty) return notebooksAsync;

  return notebooksAsync.whenData(
    (notebooks) => notebooks
        .where((n) => n.title.toLowerCase().contains(query))
        .toList(),
  );
});

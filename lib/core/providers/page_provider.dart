import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/storage/storage.dart';

/// Manages the ordered list of [PageModel]s for a single notebook.
class PageNotifier extends StateNotifier<AsyncValue<List<PageModel>>> {
  final PageDao _dao;
  final String _notebookId;

  PageNotifier(this._dao, this._notebookId)
      : super(const AsyncValue.loading()) {
    loadPages();
  }

  /// Loads all pages for the notebook, sorted by page number.
  Future<void> loadPages() async {
    state = const AsyncValue.loading();
    final result = await _dao.getByNotebookId(_notebookId);
    switch (result) {
      case Success(data: final pages):
        state = AsyncValue.data(pages);
      case Failure(message: final msg):
        state = AsyncValue.error(msg, StackTrace.current);
    }
  }

  /// Adds a new page at the end of the notebook, inheriting settings from the last page.
  Future<Result<PageModel>> addPage() async {
    final maxResult = await _dao.getMaxPageNumber(_notebookId);
    final int nextNumber;
    switch (maxResult) {
      case Success(data: final max):
        nextNumber = max + 1;
      case Failure(message: final msg, error: final err):
        return Failure(msg, err);
    }

    // Inherit template/color/spacing from the last page in memory.
    final existing = state.valueOrNull ?? [];
    final last = existing.isNotEmpty ? existing.last : null;

    final now = DateTime.now();
    final page = PageModel(
      id: const Uuid().v4(),
      notebookId: _notebookId,
      pageNumber: nextNumber,
      templateType: last?.templateType ?? 'blank',
      backgroundColor: last?.backgroundColor ?? '#FFFFFF',
      lineSpacing: last?.lineSpacing ?? 32.0,
      createdAt: now,
      updatedAt: now,
    );

    final result = await _dao.insert(page);
    switch (result) {
      case Success():
        state.whenData((pages) {
          state = AsyncValue.data([...pages, page]);
        });
        return Success(page);
      case Failure(message: final msg, error: final err):
        return Failure(msg, err);
    }
  }

  /// Deletes a page and removes it from the in-memory list.
  Future<Result<void>> deletePage(String pageId) async {
    final result = await _dao.delete(pageId);
    if (result is Success) {
      state.whenData((pages) {
        state =
            AsyncValue.data(pages.where((p) => p.id != pageId).toList());
      });
    }
    return result;
  }

  /// Moves a page to a new position by updating page numbers.
  ///
  /// All affected pages are re-numbered and persisted individually.
  Future<Result<void>> reorderPage(String pageId, int newPosition) async {
    final current = state.valueOrNull;
    if (current == null) return const Failure('Pages not loaded');

    // Clone and sort by page number so indexes match positions.
    final pages = List<PageModel>.from(current)
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

    final oldIndex = pages.indexWhere((p) => p.id == pageId);
    if (oldIndex == -1) return const Failure('Page not found');

    // Clamp newPosition into valid range (1-based).
    final clampedPosition = newPosition.clamp(1, pages.length);
    final newIndex = clampedPosition - 1;
    if (oldIndex == newIndex) return const Success(null);

    // Re-arrange.
    final moved = pages.removeAt(oldIndex);
    pages.insert(newIndex, moved);

    // Reassign page numbers and persist.
    final now = DateTime.now();
    final updated = <PageModel>[];
    for (var i = 0; i < pages.length; i++) {
      final renumbered = pages[i].copyWith(
        pageNumber: i + 1,
        updatedAt: now,
      );
      updated.add(renumbered);
      final res = await _dao.update(renumbered);
      if (res is Failure) return res;
    }

    state = AsyncValue.data(updated);
    return const Success(null);
  }
}

/// Family provider keyed by notebookId.
final pageProvider = StateNotifierProvider.family<PageNotifier,
    AsyncValue<List<PageModel>>, String>((ref, notebookId) {
  return PageNotifier(PageDao(), notebookId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/storage/storage.dart';
import 'package:study_notebook/features/auth/auth_provider.dart';
import 'package:study_notebook/features/auth/auth_state.dart';

// ──────────────────── per-course notifier ────────────────────

/// Manages notebooks that belong to a specific course.
class NotebookNotifier extends StateNotifier<AsyncValue<List<Notebook>>> {
  final NotebookDao _dao;
  final PageDao _pageDao;
  final String _courseId;
  final String _userId;

  NotebookNotifier(this._dao, this._pageDao, this._courseId, this._userId)
      : super(const AsyncValue.loading()) {
    loadNotebooks();
  }

  /// Loads all notebooks for the given course.
  Future<void> loadNotebooks() async {
    state = const AsyncValue.loading();
    final result = await _dao.getByCourseId(_courseId);
    switch (result) {
      case Success(data: final notebooks):
        state = AsyncValue.data(notebooks);
      case Failure(message: final msg):
        state = AsyncValue.error(msg, StackTrace.current);
    }
  }

  /// Creates a new notebook with an initial blank page.
  Future<Result<Notebook>> createNotebook(
    String title, {
    String pageSize = 'letter',
  }) async {
    final now = DateTime.now();
    final notebookId = const Uuid().v4();
    final notebook = Notebook(
      id: notebookId,
      courseId: _courseId,
      userId: _userId,
      title: title,
      pageSize: pageSize,
      createdAt: now,
      updatedAt: now,
    );

    final insertResult = await _dao.insert(notebook);
    switch (insertResult) {
      case Success():
        // Create the first blank page for this notebook.
        final firstPage = PageModel(
          id: const Uuid().v4(),
          notebookId: notebookId,
          pageNumber: 1,
          templateType: 'blank',
          createdAt: now,
          updatedAt: now,
        );
        await _pageDao.insert(firstPage);

        state.whenData((notebooks) {
          state = AsyncValue.data([notebook, ...notebooks]);
        });
        return Success(notebook);
      case Failure(message: final msg, error: final err):
        return Failure(msg, err);
    }
  }

  /// Updates an existing notebook and patches the in-memory list.
  Future<Result<void>> updateNotebook(Notebook notebook) async {
    final updated = notebook.copyWith(updatedAt: DateTime.now());
    final result = await _dao.update(updated);
    if (result is Success) {
      state.whenData((notebooks) {
        state = AsyncValue.data(
          notebooks.map((n) => n.id == updated.id ? updated : n).toList(),
        );
      });
    }
    return result;
  }

  /// Deletes a notebook by its ID.
  Future<Result<void>> deleteNotebook(String notebookId) async {
    final result = await _dao.delete(notebookId);
    if (result is Success) {
      state.whenData((notebooks) {
        state = AsyncValue.data(
          notebooks.where((n) => n.id != notebookId).toList(),
        );
      });
    }
    return result;
  }

  /// Toggles the favourite flag on a notebook.
  Future<Result<void>> toggleFavorite(String notebookId) async {
    final current = state.valueOrNull;
    if (current == null) return const Failure('Notebooks not loaded');

    final notebook = current.where((n) => n.id == notebookId).firstOrNull;
    if (notebook == null) return const Failure('Notebook not found');

    final toggled = notebook.copyWith(
      isFavorite: !notebook.isFavorite,
      updatedAt: DateTime.now(),
    );
    final result = await _dao.update(toggled);
    if (result is Success) {
      state = AsyncValue.data(
        current.map((n) => n.id == notebookId ? toggled : n).toList(),
      );
    }
    return result;
  }
}

/// Family provider keyed by courseId.
final notebookProvider = StateNotifierProvider.family<NotebookNotifier,
    AsyncValue<List<Notebook>>, String>((ref, courseId) {
  final authState = ref.watch(authProvider);
  final userId = switch (authState) {
    AuthAuthenticated(user: final u) => u.id,
    AuthDemo(userId: final id) => id,
    _ => '',
  };
  return NotebookNotifier(NotebookDao(), PageDao(), courseId, userId);
});

// ──────────────────── all-notebooks notifier ────────────────────

/// Manages the complete list of notebooks for the current user,
/// regardless of course — useful for an "All Notes" view.
class AllNotebooksNotifier extends StateNotifier<AsyncValue<List<Notebook>>> {
  final NotebookDao _dao;
  final String _userId;

  AllNotebooksNotifier(this._dao, this._userId)
      : super(const AsyncValue.loading()) {
    loadNotebooks();
  }

  /// Loads every notebook belonging to the current user.
  Future<void> loadNotebooks() async {
    state = const AsyncValue.loading();
    final result = await _dao.getByUserId(_userId);
    switch (result) {
      case Success(data: final notebooks):
        state = AsyncValue.data(notebooks);
      case Failure(message: final msg):
        state = AsyncValue.error(msg, StackTrace.current);
    }
  }
}

/// Provides all notebooks for the authenticated user.
final allNotebooksProvider =
    StateNotifierProvider<AllNotebooksNotifier, AsyncValue<List<Notebook>>>(
        (ref) {
  final authState = ref.watch(authProvider);
  final userId = switch (authState) {
    AuthAuthenticated(user: final u) => u.id,
    AuthDemo(userId: final id) => id,
    _ => '',
  };
  return AllNotebooksNotifier(NotebookDao(), userId);
});

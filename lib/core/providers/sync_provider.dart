import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:study_notebook/core/providers/connectivity_provider.dart';
import 'package:study_notebook/core/providers/supabase_provider.dart';
import 'package:study_notebook/core/storage/storage.dart';
import 'package:study_notebook/features/auth/auth_provider.dart';
import 'package:study_notebook/features/auth/auth_state.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;

  /// UTC timestamp of the last completed sync (null if never synced).
  final DateTime? lastSyncedAt;

  /// Total number of locally-created records that haven't been pushed yet.
  final int pendingCount;

  /// Non-null only when [status] == [SyncStatus.error].
  final String? errorMessage;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncedAt,
    this.pendingCount = 0,
    this.errorMessage,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncedAt,
    int? pendingCount,
    String? Function()? errorMessage,
  }) =>
      SyncState(
        status: status ?? this.status,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        pendingCount: pendingCount ?? this.pendingCount,
        errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Watches connectivity and automatically pushes locally-created
/// (is_synced = 0) rows to Supabase whenever the device comes back online.
///
/// Only operates for [AuthAuthenticated] users — demo-mode sessions are
/// local-only and are not synced.
class SyncNotifier extends StateNotifier<SyncState> {
  final SupabaseClient _supabase;
  final CourseDao _courseDao;
  final NotebookDao _notebookDao;
  final PageDao _pageDao;
  final DocumentDao _documentDao;
  final Ref _ref;

  SyncNotifier({
    required SupabaseClient supabase,
    required CourseDao courseDao,
    required NotebookDao notebookDao,
    required PageDao pageDao,
    required DocumentDao documentDao,
    required Ref ref,
  })  : _supabase = supabase,
        _courseDao = courseDao,
        _notebookDao = notebookDao,
        _pageDao = pageDao,
        _documentDao = documentDao,
        _ref = ref,
        super(const SyncState()) {
    // Compute pending count on startup so the badge is accurate from the start.
    _refreshPendingCount();
  }

  // ──────────────────── public API ────────────────────

  /// Called by the provider when connectivity changes.
  ///
  /// Triggers [sync] automatically when [isOffline] transitions from
  /// `true` → `false`.
  void onConnectivityChanged({
    required bool wasOffline,
    required bool isOffline,
  }) {
    if (wasOffline && !isOffline) {
      sync();
    }
  }

  /// Manually trigger an upload of all pending (is_synced=0) local records.
  ///
  /// No-ops if already syncing, or if the current user has no real session.
  Future<void> sync() async {
    final authState = _ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;
    if (state.status == SyncStatus.syncing) return;

    state = state.copyWith(status: SyncStatus.syncing, errorMessage: () => null);

    try {
      await _syncCourses();
      await _syncNotebooks();
      await _syncPages();
      await _syncDocuments();

      if (mounted) {
        state = state.copyWith(
          status: SyncStatus.success,
          lastSyncedAt: DateTime.now(),
          pendingCount: 0,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: SyncStatus.error,
          errorMessage: () => 'Sync failed: $e',
        );
        // Re-compute the real pending count after a partial failure.
        await _refreshPendingCount();
      }
    }
  }

  // ──────────────────── helpers ────────────────────

  Future<void> _refreshPendingCount() async {
    final authState = _ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    int count = 0;
    count += _countResult(await _courseDao.getUnsynced());
    count += _countResult(await _notebookDao.getUnsynced());
    count += _countResult(await _pageDao.getUnsynced());
    count += _countResult(await _documentDao.getUnsynced());

    if (mounted) {
      state = state.copyWith(pendingCount: count);
    }
  }

  int _countResult<T>(Object result) {
    if (result is Success) {
      final data = (result as Success).data;
      if (data is List) return data.length;
    }
    return 0;
  }

  // ──────────────────── per-table sync ────────────────────

  Future<void> _syncCourses() async {
    final result = await _courseDao.getUnsynced();
    if (result is! Success) return;
    final courses = (result as Success).data as List;
    if (courses.isEmpty) return;

    final rows = courses
        .map((c) => {
              'id': c.id,
              'user_id': c.userId,
              'name': c.name,
              if (c.description != null) 'description': c.description,
              if (c.color != null) 'color': c.color,
              'created_at': (c.createdAt as DateTime).toUtc().toIso8601String(),
              'updated_at': (c.updatedAt as DateTime).toUtc().toIso8601String(),
            })
        .toList();

    await _supabase.from('courses').upsert(rows);

    for (final c in courses) {
      await _courseDao.markSynced(c.id as String);
    }
  }

  Future<void> _syncNotebooks() async {
    final result = await _notebookDao.getUnsynced();
    if (result is! Success) return;
    final notebooks = (result as Success).data as List;
    if (notebooks.isEmpty) return;

    final rows = notebooks
        .map((n) => {
              'id': n.id,
              'course_id': n.courseId,
              'user_id': n.userId,
              'title': n.title,
              'page_size': n.pageSize,
              'created_at': (n.createdAt as DateTime).toUtc().toIso8601String(),
              'updated_at': (n.updatedAt as DateTime).toUtc().toIso8601String(),
              'is_favorite': n.isFavorite as bool,
            })
        .toList();

    await _supabase.from('notebooks').upsert(rows);

    for (final n in notebooks) {
      await _notebookDao.markSynced(n.id as String);
    }
  }

  Future<void> _syncPages() async {
    final result = await _pageDao.getUnsynced();
    if (result is! Success) return;
    final pages = (result as Success).data as List;
    if (pages.isEmpty) return;

    final rows = pages
        .map((p) => {
              'id': p.id,
              'notebook_id': p.notebookId,
              'page_number': p.pageNumber as int,
              'template_type': p.templateType,
              'background_color': p.backgroundColor,
              'line_spacing': p.lineSpacing as double,
              'created_at': (p.createdAt as DateTime).toUtc().toIso8601String(),
              'updated_at': (p.updatedAt as DateTime).toUtc().toIso8601String(),
            })
        .toList();

    await _supabase.from('pages').upsert(rows);

    for (final p in pages) {
      await _pageDao.markSynced(p.id as String);
    }
  }

  Future<void> _syncDocuments() async {
    final result = await _documentDao.getUnsynced();
    if (result is! Success) return;
    final documents = (result as Success).data as List;
    if (documents.isEmpty) return;

    // Only sync documents that have been successfully uploaded to Storage.
    final ready = documents.where((d) => d.status == 'ready').toList();

    if (ready.isNotEmpty) {
      final rows = ready
          .map((d) => {
                'id': d.id,
                'course_id': d.courseId,
                'user_id': d.userId,
                'file_name': d.fileName,
                'storage_path': d.storagePath,
                'page_count': d.pageCount as int,
                'status': d.status,
                'created_at': (d.createdAt as DateTime).toUtc().toIso8601String(),
              })
          .toList();

      await _supabase.from('documents').upsert(rows);
    }

    // Mark all (including non-ready) as locally processed so we don't retry
    // infinitely for documents stuck in an error/uploading state.
    for (final d in documents) {
      await _documentDao.markSynced(d.id as String);
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final syncProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);

  final notifier = SyncNotifier(
    supabase: supabase,
    courseDao: CourseDao(),
    notebookDao: NotebookDao(),
    pageDao: PageDao(),
    documentDao: DocumentDao(),
    ref: ref,
  );

  // Trigger sync automatically when the device comes back online.
  ref.listen<bool>(isOfflineProvider, (previous, isOffline) {
    notifier.onConnectivityChanged(
      wasOffline: previous ?? false,
      isOffline: isOffline,
    );
  });

  return notifier;
});

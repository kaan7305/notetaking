import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/storage/storage.dart';
import 'package:study_notebook/core/providers/supabase_provider.dart';
import 'package:study_notebook/features/auth/auth_provider.dart';
import 'package:study_notebook/features/auth/auth_state.dart';

/// Manages documents for a single course.
class DocumentNotifier extends StateNotifier<AsyncValue<List<Document>>> {
  final DocumentDao _dao;
  final SupabaseClient _supabase;
  final String _courseId;
  final String _userId;

  DocumentNotifier(this._dao, this._supabase, this._courseId, this._userId)
      : super(const AsyncValue.loading()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = const AsyncValue.loading();
    final result = await _dao.getByCourseId(_courseId);
    switch (result) {
      case Success(data: final docs):
        state = AsyncValue.data(docs);
      case Failure(message: final msg):
        state = AsyncValue.error(msg, StackTrace.current);
    }
  }

  /// Picks a file from local storage and uploads it to Supabase Storage.
  Future<Result<Document>> uploadDocument({
    required String filePath,
    required String fileName,
  }) async {
    final id = const Uuid().v4();
    final storagePath = '$_userId/$_courseId/$id/$fileName';

    // Create a local document record in 'uploading' state.
    var doc = Document(
      id: id,
      courseId: _courseId,
      userId: _userId,
      fileName: fileName,
      storagePath: storagePath,
      localPath: filePath,
      status: 'uploading',
      createdAt: DateTime.now(),
    );

    final insertResult = await _dao.insert(doc);
    if (insertResult is Failure) {
      return Failure((insertResult as Failure).message);
    }

    state.whenData((docs) {
      state = AsyncValue.data([doc, ...docs]);
    });

    // Upload to Supabase Storage.
    try {
      final file = File(filePath);
      await _supabase.storage.from('documents').upload(
            storagePath,
            file,
          );

      doc = doc.copyWith(status: 'ready', isSynced: true);
      await _dao.update(doc);

      state.whenData((docs) {
        state = AsyncValue.data(
          docs.map((d) => d.id == id ? doc : d).toList(),
        );
      });

      return Success(doc);
    } catch (e) {
      doc = doc.copyWith(status: 'error');
      await _dao.update(doc);

      state.whenData((docs) {
        state = AsyncValue.data(
          docs.map((d) => d.id == id ? doc : d).toList(),
        );
      });

      return Failure('Upload failed: $e');
    }
  }

  Future<Result<void>> deleteDocument(String docId) async {
    // Find the doc to get the storage path.
    final current = state.valueOrNull ?? [];
    final doc = current.where((d) => d.id == docId).firstOrNull;

    // Remove from Supabase Storage if it was uploaded.
    if (doc != null && doc.status == 'ready') {
      try {
        await _supabase.storage.from('documents').remove([doc.storagePath]);
      } catch (_) {
        // Best-effort remote deletion.
      }
    }

    final result = await _dao.delete(docId);
    if (result is Success) {
      state.whenData((docs) {
        state = AsyncValue.data(docs.where((d) => d.id != docId).toList());
      });
    }
    return result;
  }

  /// Returns a signed URL for viewing the document.
  Future<Result<String>> getDocumentUrl(String storagePath) async {
    try {
      final url = await _supabase.storage
          .from('documents')
          .createSignedUrl(storagePath, 3600);
      return Success(url);
    } catch (e) {
      return Failure('Could not get document URL: $e');
    }
  }
}

/// Family provider keyed by courseId.
final documentProvider = StateNotifierProvider.family<DocumentNotifier,
    AsyncValue<List<Document>>, String>((ref, courseId) {
  final supabase = ref.watch(supabaseClientProvider);
  final authState = ref.watch(authProvider);
  final userId = switch (authState) {
    AuthAuthenticated(user: final u) => u.id,
    AuthDemo(userId: final id) => id,
    _ => '',
  };
  return DocumentNotifier(DocumentDao(), supabase, courseId, userId);
});

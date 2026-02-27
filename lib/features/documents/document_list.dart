import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/app/route_names.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/document_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';

import 'upload/document_upload_sheet.dart';

/// A list view of documents for a given course.
class DocumentList extends ConsumerWidget {
  final String courseId;

  const DocumentList({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentProvider(courseId));

    return docsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(AppStrings.loadError,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  ref.read(documentProvider(courseId).notifier).loadDocuments(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (docs) {
        if (docs.isEmpty) {
          return _EmptyDocuments(courseId: courseId);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length + 1, // +1 for the upload button at top.
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _UploadButton(courseId: courseId);
            }
            return _DocumentTile(
              document: docs[index - 1],
              courseId: courseId,
            );
          },
        );
      },
    );
  }
}

class _EmptyDocuments extends StatelessWidget {
  final String courseId;
  const _EmptyDocuments({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No documents yet',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showUploadSheet(context, courseId),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload PDF'),
          ),
        ],
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  final String courseId;
  const _UploadButton({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showUploadSheet(context, courseId),
      icon: const Icon(Icons.add),
      label: const Text('Upload Document'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}

class _DocumentTile extends ConsumerWidget {
  final Document document;
  final String courseId;

  const _DocumentTile({required this.document, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReady = document.status == 'ready';
    final isError = document.status == 'error';
    final isUploading = document.status == 'uploading';

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.picture_as_pdf,
          color: isError
              ? AppColors.error
              : isUploading
                  ? Colors.grey
                  : AppColors.primary,
          size: 36,
        ),
        title: Text(
          document.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          isUploading
              ? 'Uploading...'
              : isError
                  ? 'Upload failed'
                  : document.pageCount > 0 ? '${document.pageCount} pages' : 'Ready',
          style: TextStyle(
            color: isError ? AppColors.error : Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDelete(context, ref);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: isReady
            ? () {
                context.pushNamed(
                  RouteNames.documentViewer,
                  pathParameters: {
                    'courseId': courseId,
                    'documentId': document.id,
                  },
                );
              }
            : null,
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${document.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(documentProvider(courseId).notifier)
                  .deleteDocument(document.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

void _showUploadSheet(BuildContext context, String courseId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => DocumentUploadSheet(courseId: courseId),
  );
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/document_provider.dart';

/// Screen for viewing a PDF document.
class DocumentViewerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String documentId;
  final int initialPage;

  const DocumentViewerScreen({
    super.key,
    required this.courseId,
    required this.documentId,
    this.initialPage = 1,
  });

  @override
  ConsumerState<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  String? _pdfUrl;
  String? _localPath;
  String? _error;
  bool _loading = true;
  String _title = 'Document';

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final docsAsync = ref.read(documentProvider(widget.courseId));
    final docs = docsAsync.valueOrNull ?? [];
    final doc =
        docs.where((d) => d.id == widget.documentId).firstOrNull;

    if (doc == null) {
      setState(() {
        _error = 'Document not found';
        _loading = false;
      });
      return;
    }

    setState(() => _title = doc.fileName);

    // Try local file first.
    if (doc.localPath != null && File(doc.localPath!).existsSync()) {
      setState(() {
        _localPath = doc.localPath;
        _loading = false;
      });
      return;
    }

    // Otherwise, get a signed URL from Supabase.
    final urlResult = await ref
        .read(documentProvider(widget.courseId).notifier)
        .getDocumentUrl(doc.storagePath);

    if (!mounted) return;

    switch (urlResult) {
      case Success(data: final url):
        setState(() {
          _pdfUrl = url;
          _loading = false;
        });
      case Failure(message: final msg):
        setState(() {
          _error = msg;
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    if (_localPath != null) {
      return PdfViewer.file(
        _localPath!,
        params: PdfViewerParams(
          enableTextSelection: true,
        ),
      );
    }

    if (_pdfUrl != null) {
      return PdfViewer.uri(
        Uri.parse(_pdfUrl!),
        params: PdfViewerParams(
          enableTextSelection: true,
        ),
      );
    }

    return const Center(child: Text('Unable to load document'));
  }
}

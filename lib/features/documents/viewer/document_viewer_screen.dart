import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/document_provider.dart';

/// Screen for viewing a PDF document.
///
/// When [initialPage] > 1 the viewer automatically scrolls to that page.
/// When [snippet] is provided the viewer searches for and highlights all
/// occurrences of that text, navigating to the first match.
class DocumentViewerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String documentId;

  /// 1-based page number to open (defaults to 1).
  final int initialPage;

  /// Optional text snippet to search for and highlight in the document.
  final String? snippet;

  const DocumentViewerScreen({
    super.key,
    required this.courseId,
    required this.documentId,
    this.initialPage = 1,
    this.snippet,
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

  late final PdfViewerController _pdfController;
  PdfTextSearcher? _textSearcher;

  /// Guards against calling goToPage / startTextSearch more than once.
  bool _hasNavigated = false;

  bool get _hasSnippet =>
      widget.snippet != null && widget.snippet!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    if (_hasSnippet) {
      _textSearcher = PdfTextSearcher(_pdfController);
    }
    _loadDocument();
  }

  @override
  void dispose() {
    _textSearcher?.dispose();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    final docsAsync = ref.read(documentProvider(widget.courseId));
    final docs = docsAsync.valueOrNull ?? [];
    final doc = docs.where((d) => d.id == widget.documentId).firstOrNull;

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

  /// Called by pdfrx when the viewer has fully initialised.
  void _onViewerReady(PdfDocument document, PdfViewerController controller) {
    if (_hasNavigated) return;
    _hasNavigated = true;

    // Schedule after the current frame so the layout is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Navigate to the cited page first.
      if (widget.initialPage > 1) {
        await controller.goToPage(
          pageNumber: widget.initialPage,
          anchor: PdfPageAnchor.topLeft,
          duration: const Duration(milliseconds: 400),
        );
      }

      // Then kick off a text search if a snippet was provided.
      if (_textSearcher != null && widget.snippet != null) {
        _textSearcher!.startTextSearch(
          widget.snippet!,
          caseInsensitive: true,
          goToFirstMatch: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: _hasSnippet ? [_SearchStatusBar(searcher: _textSearcher!)] : null,
      ),
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

    final params = PdfViewerParams(
      enableTextSelection: true,
      matchTextColor: Colors.yellow.withValues(alpha: 0.55),
      activeMatchTextColor: Colors.orange.withValues(alpha: 0.75),
      onViewerReady: _onViewerReady,
      pagePaintCallbacks: _hasSnippet
          ? [_paintSearchHighlights]
          : null,
    );

    if (_localPath != null) {
      return PdfViewer.file(
        _localPath!,
        controller: _pdfController,
        params: params,
      );
    }

    if (_pdfUrl != null) {
      return PdfViewer.uri(
        Uri.parse(_pdfUrl!),
        controller: _pdfController,
        params: params,
      );
    }

    return const Center(child: Text('Unable to load document'));
  }

  /// Delegates to [PdfTextSearcher.pageTextMatchPaintCallback] so that search
  /// match highlights are rendered on top of each page.
  void _paintSearchHighlights(ui.Canvas canvas, Rect pageRect, PdfPage page) {
    _textSearcher?.pageTextMatchPaintCallback(canvas, pageRect, page);
  }
}

// ---------------------------------------------------------------------------
// _SearchStatusBar — AppBar actions widget showing match count and navigation
// ---------------------------------------------------------------------------

class _SearchStatusBar extends StatelessWidget {
  final PdfTextSearcher searcher;

  const _SearchStatusBar({required this.searcher});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: searcher,
      builder: (context, _) {
        if (searcher.isSearching) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (!searcher.hasMatches) return const SizedBox.shrink();

        final current = (searcher.currentIndex ?? 0) + 1;
        final total = searcher.matches.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$current / $total',
              style: const TextStyle(fontSize: 13),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up, size: 22),
              tooltip: 'Previous match',
              onPressed: () => searcher.goToPrevMatch(),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, size: 22),
              tooltip: 'Next match',
              onPressed: () => searcher.goToNextMatch(),
            ),
          ],
        );
      },
    );
  }
}

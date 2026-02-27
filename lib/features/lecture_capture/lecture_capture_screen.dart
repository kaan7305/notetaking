import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';

import 'notes_generator/notes_generator_provider.dart';
import 'recorder/audio_recorder_widget.dart';
import 'transcription/transcription_provider.dart';

/// Screen for recording lectures, transcribing, and generating notes.
class LectureCaptureScreen extends ConsumerStatefulWidget {
  final String courseId;

  const LectureCaptureScreen({super.key, required this.courseId});

  @override
  ConsumerState<LectureCaptureScreen> createState() =>
      _LectureCaptureScreenState();
}

class _LectureCaptureScreenState extends ConsumerState<LectureCaptureScreen> {
  String? _recordingPath;

  @override
  Widget build(BuildContext context) {
    final transcriptionState = ref.watch(transcriptionProvider);
    final notesState = ref.watch(notesGeneratorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lecture Capture')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Audio recorder.
            AudioRecorderWidget(
              onRecordingComplete: (path) {
                setState(() => _recordingPath = path);
              },
            ),

            const SizedBox(height: 24),

            // Transcribe button.
            if (_recordingPath != null) ...[
              FilledButton.icon(
                onPressed: transcriptionState.isTranscribing
                    ? null
                    : () {
                        ref
                            .read(transcriptionProvider.notifier)
                            .transcribe(_recordingPath!);
                      },
                icon: transcriptionState.isTranscribing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.transcribe),
                label: Text(transcriptionState.isTranscribing
                    ? 'Transcribing...'
                    : 'Transcribe Recording'),
              ),
              const SizedBox(height: 8),
            ],

            // Transcription error.
            if (transcriptionState.error != null)
              _ErrorCard(message: transcriptionState.error!),

            // Transcript display.
            if (transcriptionState.transcript != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Transcript',
                child: SelectableText(
                  transcriptionState.transcript!,
                  style: const TextStyle(height: 1.6),
                ),
              ),

              const SizedBox(height: 16),

              // Generate notes button.
              FilledButton.icon(
                onPressed: notesState.isGenerating
                    ? null
                    : () {
                        ref
                            .read(notesGeneratorProvider.notifier)
                            .generateNotes(
                              transcriptionState.transcript!,
                              courseId: widget.courseId,
                            );
                      },
                icon: notesState.isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(notesState.isGenerating
                    ? 'Generating...'
                    : 'Generate Structured Notes'),
              ),
            ],

            // Notes generation error.
            if (notesState.error != null)
              _ErrorCard(message: notesState.error!),

            // Generated notes display.
            if (notesState.notes != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: notesState.notes!.title,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notesState.notes!.summary.isNotEmpty) ...[
                      const Text(
                        'Summary',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notesState.notes!.summary,
                        style: const TextStyle(height: 1.5),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (notesState.notes!.keyPoints.isNotEmpty) ...[
                      const Text(
                        'Key Points',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      ...notesState.notes!.keyPoints.map(
                        (point) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(fontSize: 16)),
                              Expanded(
                                child: Text(point,
                                    style: const TextStyle(height: 1.5)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const Text(
                      'Full Notes',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      notesState.notes!.fullNotes,
                      style: const TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

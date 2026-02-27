import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';

import 'audio_recorder_provider.dart';

/// Inline audio recorder widget with record/pause/stop controls.
class AudioRecorderWidget extends ConsumerWidget {
  final ValueChanged<String> onRecordingComplete;

  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recState = ref.watch(audioRecorderProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error display.
          if (recState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                recState.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),

          // Timer display.
          Text(
            _formatDuration(recState.elapsed),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: recState.status == RecordingStatus.recording
                  ? AppColors.error
                  : null,
            ),
          ),
          const SizedBox(height: 8),

          // Recording status.
          Text(
            _statusLabel(recState.status),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Controls.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (recState.status == RecordingStatus.idle ||
                  recState.status == RecordingStatus.stopped)
                _RecordButton(
                  onPressed: () => ref
                      .read(audioRecorderProvider.notifier)
                      .startRecording(),
                ),

              if (recState.status == RecordingStatus.recording) ...[
                _ControlButton(
                  icon: Icons.pause,
                  label: 'Pause',
                  onPressed: () => ref
                      .read(audioRecorderProvider.notifier)
                      .pauseRecording(),
                ),
                const SizedBox(width: 24),
                _ControlButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  color: AppColors.error,
                  onPressed: () async {
                    final path = await ref
                        .read(audioRecorderProvider.notifier)
                        .stopRecording();
                    if (path != null) onRecordingComplete(path);
                  },
                ),
              ],

              if (recState.status == RecordingStatus.paused) ...[
                _ControlButton(
                  icon: Icons.mic,
                  label: 'Resume',
                  color: AppColors.success,
                  onPressed: () => ref
                      .read(audioRecorderProvider.notifier)
                      .resumeRecording(),
                ),
                const SizedBox(width: 24),
                _ControlButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  color: AppColors.error,
                  onPressed: () async {
                    final path = await ref
                        .read(audioRecorderProvider.notifier)
                        .stopRecording();
                    if (path != null) onRecordingComplete(path);
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  String _statusLabel(RecordingStatus status) => switch (status) {
        RecordingStatus.idle => 'Tap to start recording',
        RecordingStatus.recording => 'Recording...',
        RecordingStatus.paused => 'Paused',
        RecordingStatus.stopped => 'Recording complete',
      };
}

class _RecordButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RecordButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 32),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 28),
          color: color ?? AppColors.primary,
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: (color ?? AppColors.primary).withValues(alpha: 0.1),
            minimumSize: const Size(48, 48),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

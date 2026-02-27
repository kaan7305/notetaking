import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Recording state.
enum RecordingStatus { idle, recording, paused, stopped }

class AudioRecorderState {
  final RecordingStatus status;
  final String? filePath;
  final Duration elapsed;
  final String? error;

  const AudioRecorderState({
    this.status = RecordingStatus.idle,
    this.filePath,
    this.elapsed = Duration.zero,
    this.error,
  });

  AudioRecorderState copyWith({
    RecordingStatus? status,
    String? Function()? filePath,
    Duration? elapsed,
    String? Function()? error,
  }) {
    return AudioRecorderState(
      status: status ?? this.status,
      filePath: filePath != null ? filePath() : this.filePath,
      elapsed: elapsed ?? this.elapsed,
      error: error != null ? error() : this.error,
    );
  }
}

/// Manages audio recording via the `record` package.
class AudioRecorderNotifier extends StateNotifier<AudioRecorderState> {
  final AudioRecorder _recorder;
  Timer? _timer;

  AudioRecorderNotifier()
      : _recorder = AudioRecorder(),
        super(const AudioRecorderState());

  Future<void> startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        state = state.copyWith(
          error: () => 'Microphone permission denied',
        );
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${dir.path}/lecture_$timestamp.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: path,
      );

      state = AudioRecorderState(
        status: RecordingStatus.recording,
        filePath: path,
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(error: () => 'Failed to start recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    if (state.status != RecordingStatus.recording) return;
    try {
      await _recorder.pause();
      _timer?.cancel();
      state = state.copyWith(status: RecordingStatus.paused);
    } catch (e) {
      state = state.copyWith(error: () => 'Failed to pause: $e');
    }
  }

  Future<void> resumeRecording() async {
    if (state.status != RecordingStatus.paused) return;
    try {
      await _recorder.resume();
      state = state.copyWith(status: RecordingStatus.recording);
      _startTimer();
    } catch (e) {
      state = state.copyWith(error: () => 'Failed to resume: $e');
    }
  }

  Future<String?> stopRecording() async {
    if (state.status != RecordingStatus.recording &&
        state.status != RecordingStatus.paused) {
      return null;
    }
    try {
      final path = await _recorder.stop();
      _timer?.cancel();
      state = state.copyWith(
        status: RecordingStatus.stopped,
        filePath: () => path,
      );
      return path;
    } catch (e) {
      state = state.copyWith(error: () => 'Failed to stop recording: $e');
      return null;
    }
  }

  void reset() {
    _timer?.cancel();
    state = const AudioRecorderState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}

final audioRecorderProvider =
    StateNotifierProvider<AudioRecorderNotifier, AudioRecorderState>(
  (ref) => AudioRecorderNotifier(),
);

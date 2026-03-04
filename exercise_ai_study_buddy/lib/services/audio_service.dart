import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:typed_data';
import 'dart:io';

class AudioService {
  late final AudioRecorder _audioRecorder;
  String? _recordingPath;
  bool _isRecording = false;

  AudioService() {
    _audioRecorder = AudioRecorder();
  }

  /// Check if audio recording is available
  Future<bool> isRecordingAvailable() async {
    return await _audioRecorder.hasPermission();
  }

  /// Start audio recording
  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String audioPath = (await getApplicationCacheDirectory()).path;

        audioPath =
            "${audioPath}audios/audio_${DateTime.now().millisecond}.wav";
        
        File(audioPath).createSync(recursive: true);

        await _audioRecorder.start(RecordConfig(), path: audioPath);
        _recordingPath = audioPath;
        _isRecording = true;
      }
    } catch (e) {
      throw Exception('Failed to start recording: ${e.toString()}');
    }
  }

  /// Stop recording and return audio bytes
  Future<Uint8List?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;

      if (path != null) {
        _recordingPath = path;
        final file = File(path);
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to stop recording: ${e.toString()}');
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _isRecording = false;
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to cancel recording: ${e.toString()}');
    }
  }

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Dispose audio recorder
  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}

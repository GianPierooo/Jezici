import 'voice_recorder.dart';

VoiceRecorder createVoiceRecorderImpl() => _StubRecorder();

/// Fuera de web no hay grabación de notas de voz (degradación honesta).
class _StubRecorder implements VoiceRecorder {
  @override
  Future<String?> start() async => 'unsupported';
  @override
  Future<VoiceRecording?> stop() async => null;
  @override
  void cancel() {}
  @override
  bool get isRecording => false;
}

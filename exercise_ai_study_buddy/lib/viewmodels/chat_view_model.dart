import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../services/audio_service.dart';

class ChatViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();
  final AudioService _audioService = AudioService();

  final List<Message> _messages = [
    Message.ai("Hello! I'm your AI Study Buddy. How can I help you today?"),
  ];

  late final ValueNotifier<bool> isLoadingNotifier;
  late final ValueNotifier<List<Message>> messagesNotifier;
  late final ValueNotifier<bool> isRecordingNotifier;

  ChatViewModel() {
    isLoadingNotifier = ValueNotifier(false);
    messagesNotifier = ValueNotifier([..._messages]);
    isRecordingNotifier = ValueNotifier(false);
  }

  List<Message> get messages => messagesNotifier.value;
  bool get isLoading => isLoadingNotifier.value;
  bool get isRecording => isRecordingNotifier.value;

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty || isLoadingNotifier.value) return;

    // Add user message
    _messages.add(Message.user(userMessage));
    messagesNotifier.value = [..._messages];

    isLoadingNotifier.value = true;

    try {
      // Send to AI
      final aiResponse = await _aiService.sendMessage(userMessage);
      _messages.add(Message.ai(aiResponse));
      messagesNotifier.value = [..._messages];
    } catch (e) {
      _messages.add(Message.ai(
        "Sorry, I encountered an error: ${e.toString()}",
      ));
      messagesNotifier.value = [..._messages];
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Start recording audio
  Future<void> startAudioRecording() async {
    try {
      final hasPermission = await _audioService.isRecordingAvailable();
      if (hasPermission) {
        await _audioService.startRecording();
        isRecordingNotifier.value = true;
      }
    } catch (e) {
      // Recording start failed silently
    }
  }

  /// Stop recording and send audio to AI
  Future<void> stopAndSendAudio() async {
    try {
      isRecordingNotifier.value = false;
      final audioBytes = await _audioService.stopRecording();

      if (audioBytes != null) {
        await sendAudio(audioBytes);
      }
    } catch (e) {
      _messages.add(Message.ai("Error processing audio: ${e.toString()}"));
      messagesNotifier.value = [..._messages];
    }
  }

  /// Cancel audio recording
  Future<void> cancelAudioRecording() async {
    try {
      await _audioService.cancelRecording();
      isRecordingNotifier.value = false;
    } catch (e) {
      // Cancel recording failed silently
    }
  }

  /// Send audio bytes to AI
  Future<void> sendAudio(Uint8List audioBytes) async {
    if (isLoadingNotifier.value) return;

    // Add user's audio message bubble (persists in chat)
    _messages.add(Message.userAudio());
    messagesNotifier.value = [..._messages];

    isLoadingNotifier.value = true;

    try {
      // Send audio bytes as InlineDataPart to AI
      final aiResponse = await _aiService.sendAudioTranscript(audioBytes);
      _messages.add(Message.ai(aiResponse));
      messagesNotifier.value = [..._messages];
    } catch (e) {
      _messages.add(Message.ai(
        "Sorry, I couldn't process the audio: ${e.toString()}",
      ));
      messagesNotifier.value = [..._messages];
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  void resetChat() {
    _messages.clear();
    _messages.add(Message.ai("Hello! I'm your AI Study Buddy. How can I help you today?"));
    messagesNotifier.value = [..._messages];
    _aiService.resetChat();
  }

  @override
  void dispose() {
    isLoadingNotifier.dispose();
    messagesNotifier.dispose();
    isRecordingNotifier.dispose();
    _audioService.dispose();
    super.dispose();
  }
}

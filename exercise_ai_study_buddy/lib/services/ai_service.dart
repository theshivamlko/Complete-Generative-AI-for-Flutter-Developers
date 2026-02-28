import 'package:firebase_vertexai/firebase_vertexai.dart';

class AIService {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  AIService() {
    _initialize();
  }

  void _initialize() {
    // Initialize the Gemini model
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-flash',
      systemInstruction: Content.system(
        'You are a helpful AI Study Buddy assistant. Your role is to help students '
        'learn, understand concepts, answer questions, create quizzes, and provide '
        'educational support. Be encouraging, clear, and concise in your responses. '
        'Break down complex topics into simpler explanations when needed.',
      ),
    );

    // Start a chat session
    _chatSession = _model.startChat();
  }

  /// Send a message to the AI and get a response
  Future<String> sendMessage(String message) async {
    try {
      final response = await _chatSession.sendMessage(
        Content.text(message),
      );

      return response.text ?? "I'm sorry, I couldn't generate a response.";
    } catch (e) {
      throw Exception('Failed to get AI response: ${e.toString()}');
    }
  }

  /// Get a list of chat history
  List<Content> getChatHistory() {
    return _chatSession.history.toList();
  }

  /// Clear chat history and start a new session
  void resetChat() {
    _chatSession = _model.startChat();
  }
}


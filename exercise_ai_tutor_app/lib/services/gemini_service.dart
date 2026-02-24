import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

 
class GeminiService {

  /// The Gemini model to use.
  static const String _model = 'gemini-2.5-flash';


  late final GenerativeModel _generativeModel;
  late ChatSession _chat; // non-final so resetChat() can reassign it

  // ── Constructor ───────────────────────────────────────────────────────────

  GeminiService({required String apiKey}) {
    _generativeModel = GenerativeModel(
      model: _model,
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are a helpful, friendly AI Tutor for school children. You solve follwing cases '
        '1. Explain concepts clearly with examples. \n '
        '2. Analyse images and provide insights ro solves question given in image \n '
        'Keep answers concise unless the user asks for more detail.',
      ),
    );
    _chat = _generativeModel.startChat();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Sends [text] (and an optional [imagePath]) to Gemini and returns a
  /// [Stream<String>] that emits each text chunk as it is received.
  ///
  /// Conversation history is automatically maintained by [_chat].
  Stream<String> sendMessageStream(String text, {String? imagePath}) async* {
    try {
      final parts = <Part>[];

      // Attach image if provided
      if (imagePath != null) {
        final bytes = await File(imagePath).readAsBytes();
        // Detect MIME type from extension
        final ext = imagePath.split('.').last.toLowerCase();
        final mime = _mimeType(ext);
        parts.add(DataPart(mime, bytes));
      }

      // Always add text (may be empty string if only an image was sent)
      parts.add(TextPart(text.isNotEmpty ? text : 'Describe this image.'));

      final response = _chat.sendMessageStream(Content.multi(parts));

      await for (final chunk in response) {
        final chunkText = chunk.text;
        if (chunkText != null && chunkText.isNotEmpty) {
          yield chunkText;
        }
      }
    } catch (e) {
      yield '\u26a0\ufe0f Error: ${e.toString()}';
    }
  }

  /// Resets conversation history, starting a fresh chat session.
  void resetChat() {
    _chat = _generativeModel.startChat();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _mimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'image/jpeg';
    }
  }
}

import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'weather_tools.dart';

class WeatherChatService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String _modelName = 'gemini-2.5-flash';

  static late final GenerativeModel _model = GenerativeModel(
    model: _modelName,
    apiKey: _apiKey,
    tools: [WeatherTools.weatherTool],
    systemInstruction: Content.system(
      'You are WeatherBot, a friendly weather assistant. '
      'When users ask about weather in a specific city, use the get_current_weather function. '
      'Provide weather information in a conversational, helpful manner with emojis. '
      'Format temperatures, conditions, and other details clearly.',
    ),
  );

  static Future<String> getResponse(String message) async {
    if (_apiKey.isEmpty) {
      return 'Missing API key. Run the app with '
          '--dart-define=GEMINI_API_KEY=YOUR_KEY.';
    }

    try {
      final chat = _model.startChat();
      var response = await chat.sendMessage(Content.text(message));

      // Handle function calls
      while (response.functionCalls.isNotEmpty) {
        final functionCall = response.functionCalls.first;
        final functionResponse = await WeatherTools.handleFunctionCall(functionCall);

        response = await chat.sendMessage(
          Content.functionResponse(functionCall.name, {
            'result': functionResponse,
          }),
        );
      }

      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        return 'I did not get a response. Try again with a different question.';
      }
      return text;
    } catch (e) {
      return 'Something went wrong: ${e.toString()}';
    }
  }
}

import 'dart:async';
import 'package:exercise_weather_app/services/permission_tools.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'weather_tools.dart';

class WeatherChatService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String _modelName = 'gemini-2.5-flash';

  static late final GenerativeModel _model = GenerativeModel(
    model: _modelName,
    apiKey: _apiKey,
    tools: [WeatherTools.weatherTool,PermissionTools.permissionTool],
    systemInstruction: Content.system(
      'You are WeatherBot, a friendly weather assistant. '
      '\n\nWORKFLOW FOR CURRENT LOCATION WEATHER:'
      '\n1. When user asks for weather at "current location", "here", "my location", or similar:'
      '\n   - First, call check_location_permission to verify permission status'
      '\n   - If permission is NOT granted, call request_location_permission'
      '\n   - After permission is granted, call get_current_location to get GPS coordinates'
      '\n   - Use the returned coordinates (in format "lat,long") to call get_current_weather'
      '\n\n2. When user asks for weather in a specific city:'
      '\n   - Directly call get_current_weather with the city name'
      '\n\n3. Always provide weather information in a conversational, helpful manner with emojis.'
      '\n4. Format temperatures, conditions, and other details clearly.'
      '\n\nIMPORTANT: For current location requests, you MUST check/request permission before getting location.',
    ),
  );
  static final chat = _model.startChat();

  static Future<String> getResponse(String message) async {
    if (_apiKey.isEmpty) {
      return 'Missing API key. Run the app with '
          '--dart-define=GEMINI_API_KEY=YOUR_KEY.';
    }

    try {
      var response = await chat.sendMessage(Content.text(message));

      // Handle function calls
      while (response.functionCalls.isNotEmpty) {
        final functionCall = response.functionCalls.first;
        print('🔧 Function called: ${functionCall.name}');
        print('📥 Arguments: ${functionCall.args}');

        // Route to appropriate tool handler
        String functionResponse;
        if (functionCall.name == 'get_current_weather') {
          functionResponse = await WeatherTools.handleFunctionCall(functionCall);
          print('🌤️ Weather response: $functionResponse');
        } else if (functionCall.name == 'check_location_permission' ||
            functionCall.name == 'request_location_permission' ||
            functionCall.name == 'get_current_location') {
          functionResponse = await PermissionTools.handleFunctionCall(functionCall);
          print('📍 Permission response: $functionResponse');
        } else {
          functionResponse = '{"error": "Unknown function"}';
          print('❌ Unknown function: ${functionCall.name}');
        }

        response = await chat.sendMessage(
          Content.functionResponse(functionCall.name, {
            'result': functionResponse,
          }),
        );
        print('💬 AI processed function result\n');
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

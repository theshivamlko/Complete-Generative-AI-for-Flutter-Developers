import 'dart:async';
import 'package:exercise_weather_app/services/permission_tools.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'weather_tools.dart';

class WeatherChatService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String _modelName = 'gemini-2.5-flash-lite';

  // add ReAct here
  static late final GenerativeModel _model = GenerativeModel(
    model: _modelName,
    apiKey: _apiKey,
    tools: [WeatherTools.weatherTool,PermissionTools.permissionTool],
    systemInstruction: Content.system("""
You are WeatherBot, a helpful assistant dedicated to providing accurate weather updates. 
Your goal is to answer weather-related questions by using your tools to fetch real-time data.

### Operational Rules:


1. **No city Name Found or Current Location**: If the user asks for the weather at their current location or u don't have context of city name that user has asked 
then fetch lat long of current location to find the weather: ":
    - Call `check_location_permission`.
    - If denied, call `request_location_permission`.
    - If allowed, call `get_current_location` to get GPS coordinates.
    - If no city name is provided fetch co-ordinates from GPS, else ask user for city name. 
    - Finally, fetch weather using those coordinates or city name , call get_current_weather.
    
    
1. **Specific City**: If the user asks for the weather in a specific city, use the city name 
   provided to call the get_current_weather tool directly.
 
 
3. **Tone & Style**: Always present data with clear formatting and helpful emojis (e.g., ☀️, 🌧️).

4. **Scope Constraint**: If a user asks a question unrelated to weather, politely inform 
   them that you are a specialized weather assistant and cannot help with other topics.
   
   EXAMPLE:
   The weather in London is Sunny ☀️, and temperate is 32 °C.
    
    """
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
        print('Function called: ${functionCall.name}');
        print('Arguments: ${functionCall.args}');

        // Route to appropriate tool handler
        String functionResponse;
        if (functionCall.name == 'get_current_weather') {
          functionResponse = await WeatherTools.handleFunctionCall(functionCall);
          print('Weather response: $functionResponse');
        } else if (functionCall.name == 'check_location_permission' ||
            functionCall.name == 'request_location_permission' ||
            functionCall.name == 'get_current_location') {
          functionResponse = await PermissionTools.handleFunctionCall(functionCall);
          print('Permission response: $functionResponse');
        } else {
          functionResponse = '{"error": "Unknown function"}';
          print('Unknown function: ${functionCall.name}');
        }

        response = await chat.sendMessage(
          Content.functionResponse(functionCall.name, {
            'result': functionResponse,
          }),
        );
        print('AI processed function result\n');
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

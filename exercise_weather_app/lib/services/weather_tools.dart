import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherTools {
  static const String _baseUrl = 'http://api.weatherapi.com/v1/current.json';

  static final Tool weatherTool = Tool(
    functionDeclarations: [
      FunctionDeclaration(
        'get_current_weather',
        'Get current weather information for a specific city',
        Schema(
          SchemaType.object,
          properties: {
            'city': Schema(
              SchemaType.string,
              description: 'The name of the city to get weather for',
            ),
          },
          requiredProperties: ['city'],
        ),
      ),
    ],
  );

  static Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final String _weatherApiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
    if (_weatherApiKey.isEmpty) {
      return {
        'error':
            'Missing Weather API key',
      };
    }

    try {
      final uri = Uri.parse('$_baseUrl?key=$_weatherApiKey&q=$city&aqi=no');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'city': data['location']['name'],
          'country': data['location']['country'],
          'temperature_c': data['current']['temp_c'],
          'temperature_f': data['current']['temp_f'],
          'condition': data['current']['condition']['text'],
          'humidity': data['current']['humidity'],
          'wind_kph': data['current']['wind_kph'],
          'feels_like_c': data['current']['feelslike_c'],
        };
      } else {
        return {
          'error':
              'Could not fetch weather for $city. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'error': 'Failed to get weather data: ${e.toString()}'};
    }
  }

  static Future<String> handleFunctionCall(FunctionCall functionCall) async {
    if (functionCall.name == 'get_current_weather') {
      final city = functionCall.args['city'] as String;
      final weatherData = await getCurrentWeather(city);
      return jsonEncode(weatherData);
    }
    return jsonEncode({'error': 'Unknown function: ${functionCall.name}'});
  }
}

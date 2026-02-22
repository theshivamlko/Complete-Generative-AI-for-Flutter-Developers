import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiAiServices {
  
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    Future<String> summarizeText(String text) async {

    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'API key not found. Please set GEMINI_API_KEY in .env file.',
      );
    }


    final headers = {'Content-Type': 'application/json', 'x-goog-api-key': apiKey};

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "Summarize the following text, provider answer as \n if the user is new to Ai but has coding experience:\n\n$text"},
          ],
        },
      ],
    });

    try {
      final response = await http.post(Uri.parse(_baseUrl), headers: headers, body: body);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final content =
            decodedResponse['candidates'][0]['content']['parts'][0]['text'];
        return content as String;
      } else {
        throw Exception(
          'Failed to communicate with Gemini API: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error calling Gemini API: $e');
    }
  }
}

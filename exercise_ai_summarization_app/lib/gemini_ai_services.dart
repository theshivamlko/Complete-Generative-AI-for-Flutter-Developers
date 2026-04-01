import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiAiServices {
  static String modelId = "gemini-3.1-flash-lite-preview";

  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$modelId:generateContent';

  Future<String> summarizeText(String text) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'API key not found. Please set GEMINI_API_KEY in .env file.',
      );
    }

    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    };

    final body = jsonEncode({
      "system_instruction":
      {
        "parts": [
          {
            "text": """
            
            
              Act as Teacher, who teaches AI to developers.
                  
                  Explain the following topic, provider answer as \n if the user is new to Ai .
                   Do answer in points ,  Add 1 Examples everytime . \n 
                   
                   Output:
                   
                   Example 1:
                   Here is a summary of the 6 tools and strategies mentioned:

1. Figma (Developer Mode) 🌈
While traditionally a design tool, the author highlights "Dev Mode" as a bridge that eliminates guesswork. It allows engineers to inspect CSS properties, colors, and layout dimensions directly, reducing the back-and-forth between design and development teams.

2. Warp (Modern Terminal) 🌷
The author suggests moving away from standard terminals like Zsh or Bash in favor of Warp. It provides an AI-integrated, collaborative terminal experience with features like "blocks" (which treat commands and outputs as distinct units) and a command search that uses natural language.

3. Raycast ☀️
Raycast is described as a "supercharged" replacement for macOS Spotlight. It acts as a command center for productivity—allowing you to manage your clipboard history, search through documentation, or trigger custom scripts with a single keyboard shortcut.

4. Tailscale ⚠️
This tool is recommended for handling networking and VPN needs without the complexity. It allows you to create a secure "mesh" network between your devices (like your work laptop, home server, and phone) effortlessly, which is particularly useful for testing cross-device applications or accessing local databases remotely.

5. Postman (with Environments)💡
Beyond just testing APIs, the article emphasizes using Environments and Variables. By switching between "Local," "Staging," and "Production" configurations instantly, engineers can avoid hardcoding sensitive keys and reduce the risk of accidental production data mutations.

6. Obsidian (with Canvas) 🌀
For documentation and "Second Brain" management, the author leans on Obsidian. Specifically, the Canvas feature is highlighted as a way to visualize complex system architectures and logic flows using an infinite whiteboard, keeping your thoughts organized as your project grows.
                   
            
            """
          }
        ]
      },


      "contents": [
        {
          "parts": [
            {
              "text":
                  """
                
                   
                   User Input:\n\n$text""",
            },
          ],
        },
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print(response.body);
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

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static Future<File> generateAnimeImage(
    File selectedImage,
    String selectedFilter,
  ) async {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
      throw Exception('Please set GEMINI_API_KEY first.');
    }

    final bytes = await selectedImage.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent',
    );

    final prompt =
        """
        
## AGENT ROLE
        Act as a creative image-to-anime transformation engine. Your goal is to reimagine a provided image in a high-quality anime aesthetic.

## INSTRUCTIONS

Follow these strict transformation rules:
1. STYLE: Match the specific artistic nuances, line work, and color palette of the requested filter.
2. BACKGROUND: Redesign the environment to be fully immersive and consistent with the chosen anime style.
3. POSING: Adjust the character's pose to be cool, calm, or contextually appropriate based on the vibe of the selected filter.
4. FIDELITY: Ensure the output quality is professional-grade and rivals the original source material of that style.

## INPUT DATA
Filter Style: $selectedFilter
Image: [Image Attachment]
        
        """;

    final response = await http.post(
      url,
      headers: {'x-goog-api-key': apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": {
          "responseModalities": ["IMAGE"],
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final parts = data['candidates'][0]['content']['parts'];
        String? base64Result;

        for (var part in parts) {
          if (part.containsKey('inlineData')) {
            base64Result = part['inlineData']['data'];
            break;
          }
        }

        if (base64Result != null) {
          final directory = await getTemporaryDirectory();
          final imagePath =
              '${directory.path}\\makeMeAnime\\anime_result_${DateTime.now().millisecondsSinceEpoch}.png';

          final resultFile = File(imagePath);

          if (!resultFile.existsSync()) {
            resultFile.createSync(recursive: true);
          }
          await resultFile.writeAsBytes(base64Decode(base64Result));

          return resultFile;
        }
      }
      throw Exception('No image data in response');
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<File> editImage(File imageFile, String prompt) async {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
      throw Exception('Please set GEMINI_API_KEY first.');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent',
    );

    final response = await http.post(
      url,
      headers: {'x-goog-api-key': apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": {
          "responseModalities": ["IMAGE"],
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final parts = data['candidates'][0]['content']['parts'];
        String? base64Result;

        for (var part in parts) {
          if (part.containsKey('inlineData')) {
            base64Result = part['inlineData']['data'];
            break;
          }
        }

        if (base64Result != null) {
          final directory = await getTemporaryDirectory();
          final imagePath =
              '${directory.path}\\makeMeAnime\\anime_edit_${DateTime.now().millisecondsSinceEpoch}.png';

          final resultFile = File(imagePath);

          if (!resultFile.existsSync()) {
            resultFile.createSync(recursive: true);
          }
          await resultFile.writeAsBytes(base64Decode(base64Result));

          return resultFile;
        }
      }
      throw Exception('No image data in response');
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}

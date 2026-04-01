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
        """Be creative and make the given image into an anime style specifically $selectedFilter filter.
         The image should be near as good as $selectedFilter anime styles, the background should be too match the $selectedFilter style. 
         Change the pose of the persons in the image to some cool or calm or appropriate post according to $selectedFilter style.""";

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
}

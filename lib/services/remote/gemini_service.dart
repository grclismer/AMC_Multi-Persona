import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amc_persona/core/constants/api_config.dart';

class GeminiService {
  final String systemInstruction;

  // Switched to v1beta to support the official system_instruction field
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  GeminiService({required this.systemInstruction});

  Future<String?> generateResponse(List<Map<String, String>> history) async {
    try {
      // Format the conversation history correctly for the API
      final List<Map<String, dynamic>> contents = history.map((msg) {
        return {
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [
            {'text': msg['text']},
          ],
        };
      }).toList();

      final response = await http.post(
        Uri.parse('$apiUrl?key=${ApiConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Official way to set the persona/behavior
          'system_instruction': {
            'parts': [
              {'text': systemInstruction},
            ],
          },
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 800,
            'topP': 0.95,
            'topK': 40,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Safety check for empty candidates
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return "No response generated. Please try again.";
        }
      } else {
        // Helpful for debugging: returns the specific API error
        return "ERROR ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "ERROR: $e";
    }
  }
}

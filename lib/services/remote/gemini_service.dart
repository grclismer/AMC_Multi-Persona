import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amc_persona/core/constants/api_config.dart';

class GeminiService {
  final String systemInstruction;
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  GeminiService({required this.systemInstruction});

  // 🔥 CONVERT MESSAGES TO GEMINI FORMAT
  List<Map<String, dynamic>> _formatMessages(
    List<Map<String, String>> history,
  ) {
    return history.map((msg) {
      return {
        'role': msg['role'], // "user" or "model"
        'parts': [
          {'text': msg['text']},
        ],
      };
    }).toList();
  }

  Future<String?> generateResponse(List<Map<String, String>> history) async {
    try {
      final formattedMessages = _formatMessages(history);

      final response = await http.post(
        Uri.parse('$apiUrl?key=${ApiConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': systemInstruction},
            ],
          },
          'contents': formattedMessages,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 1,
            'topP': 1,
            'maxOutputTokens': 500,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else if (response.statusCode == 429) {
        return "ERROR: I'm feeling a bit tired from all the puns! Please wait about 60 seconds and try again. (Quota Exceeded)";
      } else {
        return "ERROR: Something went wrong (Status ${response.statusCode}). Please try again later.";
      }
    } catch (e) {
      return "ERROR: Network Error - $e";
    }
  }
}

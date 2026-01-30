import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amc_persona/core/constants/api_config.dart';

class GeminiService {
  final String systemInstruction;
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

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
      } else {
        final errorBody = response.body;
        final statusCode = response.statusCode;

        if (statusCode == 429) {
          return "ERROR: Quota exceeded. Please wait a moment and try again.";
        }

        // Return a detailed error if possible
        try {
          final errorData = jsonDecode(errorBody);
          final errorMessage = errorData['error']['message'] ?? "Unknown Error";
          return "ERROR $statusCode: $errorMessage";
        } catch (_) {
          return "ERROR $statusCode: Something went wrong. Status ${response.statusCode}";
        }
      }
    } catch (e) {
      return "ERROR: Network Error - $e";
    }
  }
}

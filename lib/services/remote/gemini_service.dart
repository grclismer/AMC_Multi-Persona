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
            'maxOutputTokens': 1024,
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
          return "ERROR: The AI was unable to generate a response for this request.";
        }
      } else {
        final statusCode = response.statusCode;
        if (statusCode == 429) {
          return "ERROR: [QUOTA_LIMIT] You've reached your free daily limit for this Persona. Your quota will reset automatically within 24 hours. (Tip: Try a different Persona or check back tomorrow!)";
        } else if (statusCode == 404) {
          return "ERROR: [SERVER_NOT_FOUND] The AI service is currently unavailable for this model. Please try again later.";
        } else if (statusCode == 400) {
          return "ERROR: [INVALID_REQUEST] There was a technical issue with the message format. Please try rephrasing.";
        }
        return "ERROR: [$statusCode] Something went wrong on the server. Please try again later.";
      }
    } catch (e) {
      return "ERROR: [NETWORK_ISSUE] Unable to connect to the AI. Check your internet connection.";
    }
  }
}

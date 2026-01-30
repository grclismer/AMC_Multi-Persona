import 'package:amc_persona/services/remote/gemini_service.dart';
import 'package:amc_persona/services/local/local_storage_service.dart';
import 'package:amc_persona/services/remote/firebase_service.dart';
import 'package:amc_persona/model/chat_session.dart';

class GeminiRepository {
  final _firebaseService = FirebaseService();

  // Methods for AI Generation
  Future<String?> generateAIResponse({
    required String systemInstruction,
    required List<Map<String, String>> history,
  }) async {
    final service = GeminiService(systemInstruction: systemInstruction);
    return await service.generateResponse(history);
  }

  // Methods for Local Storage (matches "Local Service" in diagram)
  List<ChatSession> getLocalSessions(String personaId) {
    return LocalStorageService.getSessions(personaId);
  }

  Future<void> saveSession(ChatSession session) async {
    // 1. Save to Local Persistence (Hive)
    await LocalStorageService.saveSession(session);

    // 2. Sync to Backend Services (Firebase)
    // Matches "Background Synchronization" in diagram
    await _firebaseService.syncSessionToCloud(session);
  }

  Future<void> deleteSession(String sessionId) async {
    await LocalStorageService.deleteSession(sessionId);
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:amc_persona/model/message.dart';
import 'package:amc_persona/model/chat_session.dart';

class LocalStorageService {
  static const String sessionBoxName = 'chat_sessions';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChatSessionAdapter());
    }

    // Open Boxes
    await Hive.openBox<ChatSession>(sessionBoxName);
  }

  static List<ChatSession> getSessions(String personaId) {
    final box = Hive.box<ChatSession>(sessionBoxName);
    return box.values.where((s) => s.personaId == personaId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> saveSession(ChatSession session) async {
    final box = Hive.box<ChatSession>(sessionBoxName);
    await box.put(session.id, session);
  }

  static Future<void> deleteSession(String sessionId) async {
    final box = Hive.box<ChatSession>(sessionBoxName);
    await box.delete(sessionId);
  }
}

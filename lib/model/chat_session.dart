import 'package:hive/hive.dart';
import 'package:amc_persona/model/message.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 1)
class ChatSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String personaId;

  @HiveField(2)
  final List<Message> messages;

  @HiveField(3)
  final DateTime timestamp;

  ChatSession({
    required this.id,
    required this.personaId,
    required this.messages,
    required this.timestamp,
  });

  String get title {
    if (messages.isEmpty) return "New Conversation";
    final firstMsg = messages.firstWhere((m) => m.isUser).text;
    return firstMsg.length > 30 ? '${firstMsg.substring(0, 30)}...' : firstMsg;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personaId': personaId,
      'messages': messages.map((m) => m.toMap()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amc_persona/model/message.dart';
import 'package:amc_persona/model/persona.dart';
import 'package:amc_persona/model/chat_session.dart';
import 'package:amc_persona/services/remote/gemini_service.dart';
import 'package:amc_persona/services/local/local_storage_service.dart';
import 'package:uuid/uuid.dart';

// Chat State
class ChatState {
  final List<Message> messages;
  final List<ChatSession> historySessions;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.historySessions = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    List<ChatSession>? historySessions,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      historySessions: historySessions ?? this.historySessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends FamilyNotifier<ChatState, String> {
  late GeminiService _geminiService;
  String? _currentSessionId;

  @override
  ChatState build(String arg) {
    // Load history for this persona
    final history = LocalStorageService.getSessions(arg);

    // Auto-archive when the provider is disposed (user leaves the screen)
    ref.onDispose(() {
      _archiveSync(arg);
    });

    return ChatState(messages: [], historySessions: history);
  }

  void _initService(Persona persona) {
    _geminiService = GeminiService(
      systemInstruction: persona.systemInstruction,
    );
  }

  // Synchronous version for onDispose
  void _archiveSync(String personaId) {
    if (state.messages.isEmpty) return;

    final session = ChatSession(
      id: _currentSessionId ?? const Uuid().v4(),
      personaId: personaId,
      messages: state.messages,
      timestamp: DateTime.now(),
    );

    // Hive boxes are already open, so put is fast
    LocalStorageService.saveSession(session);
  }

  void archiveCurrentSession(String personaId) async {
    _archiveSync(personaId);

    // Refresh history list
    final updatedHistory = LocalStorageService.getSessions(personaId);
    state = state.copyWith(
      messages: [], // Clear main chat
      historySessions: updatedHistory,
    );
    _currentSessionId = null;
  }

  void loadHistoricalSession(ChatSession session) {
    state = state.copyWith(
      messages: session.messages,
      isLoading: false,
      error: null,
    );
    _currentSessionId = session.id;
  }

  void startNewChat(String personaId) {
    archiveCurrentSession(personaId);
  }

  Future<void> sendMessage(String text, Persona persona) async {
    if (text.trim().isEmpty) return;

    _initService(persona);

    if (_currentSessionId == null && state.messages.isEmpty) {
      _currentSessionId = const Uuid().v4();
    }

    // Add User Message
    final userMessage = Message(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final history = state.messages.map((m) {
        return {'role': m.isUser ? 'user' : 'model', 'text': m.text};
      }).toList();

      final responseText = await _geminiService.generateResponse(history);

      if (responseText != null) {
        if (responseText.startsWith("ERROR:")) {
          state = state.copyWith(
            isLoading: false,
            error: responseText.replaceFirst("ERROR:", "").trim(),
          );
          return;
        }

        final aiMessage = Message(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, aiMessage],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final chatStateProvider =
    NotifierProvider.family<ChatNotifier, ChatState, String>(() {
      return ChatNotifier();
    });

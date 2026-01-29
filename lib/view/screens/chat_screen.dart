import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amc_persona/core/constants/persona_data.dart';
import 'package:amc_persona/model/message.dart';
import 'package:amc_persona/view_model/chat_view_model.dart';
import 'package:amc_persona/view/widgets/history_drawer.dart';

class ChatScreen extends ConsumerWidget {
  final String personaId;

  const ChatScreen({super.key, required this.personaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = PersonaData.personas.firstWhere(
      (p) => p.id == personaId,
      orElse: () => PersonaData.personas.first,
    );

    final chatState = ref.watch(chatStateProvider(personaId));

    // Listen for errors and show snackbar
    ref.listen<ChatState>(chatStateProvider(personaId), (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      endDrawer: HistoryDrawer(personaId: personaId),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(persona.icon, color: Colors.black),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                persona.name,
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              ref
                  .read(chatStateProvider(personaId).notifier)
                  .startNewChat(personaId);
            },
            tooltip: 'New Chat',
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'History',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: chatState.messages.isEmpty && !chatState.isLoading
                ? Center(
                    child: Text(
                      'Start a conversation with\n${persona.role}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        chatState.messages.length +
                        (chatState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= chatState.messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final message = chatState.messages[index];
                      return _ChatBubble(
                        message: message,
                        personaColor: persona.color,
                      );
                    },
                  ),
          ),

          // Input Area
          _ChatInput(
            onSubmitted: (text) {
              ref
                  .read(chatStateProvider(personaId).notifier)
                  .sendMessage(text, persona);
            },
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;
  final Color personaColor;

  const _ChatBubble({required this.message, required this.personaColor});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFE0E0E0)
              : const Color(
                  0xFFE8F5E9,
                ), // Grey for User, Light Green for Bot (placeholder)
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: !isUser
              ? Border.all(color: const Color(0xFF64FF64), width: 1)
              : null,
        ),
        child: Text(
          message.text,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}

class _ChatInput extends StatefulWidget {
  final Function(String) onSubmitted;

  const _ChatInput({required this.onSubmitted});

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  final _controller = TextEditingController();

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSubmitted(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _submit,
            icon: const Icon(
              Icons.send,
              color: Color(0xFF2E7D32),
            ), // Dark Green
          ),
        ],
      ),
    );
  }
}

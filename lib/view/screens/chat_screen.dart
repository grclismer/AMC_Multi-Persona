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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(persona.icon, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation with\n${persona.role}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        itemCount:
                            chatState.messages.length +
                            (chatState.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= chatState.messages.length) {
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                  ),
          ),

          // Input Area
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _ChatInput(
                onSubmitted: (text) {
                  ref
                      .read(chatStateProvider(personaId).notifier)
                      .sendMessage(text, persona);
                },
              ),
            ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth > 700 ? 550.0 : screenWidth * 0.8;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        decoration: BoxDecoration(
          color: isUser ? Colors.grey[100] : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser
                ? const Radius.circular(20)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
          border: !isUser
              ? Border.all(
                  color: const Color(0xFF64FF64).withValues(alpha: 0.5),
                  width: 1,
                )
              : Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.4,
          ),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _submit,
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

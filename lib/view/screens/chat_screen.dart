import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amc_persona/core/constants/persona_data.dart';
import 'package:amc_persona/model/message.dart';
import 'package:amc_persona/view_model/chat_view_model.dart';
import 'package:amc_persona/view/widgets/history_drawer.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import 'package:amc_persona/core/theme/design_system.dart';
import 'package:amc_persona/view/widgets/app_branding.dart';

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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });

    return Scaffold(
      endDrawer: HistoryDrawer(personaId: personaId),
      body: AppBackground(
        showHeaderCircles: false, // Cleaner for chat
        child: Column(
          children: [
            // Branded AppBar
            _buildAppBar(context, ref, persona),

            // Chat List
            Expanded(
              child: chatState.messages.isEmpty && !chatState.isLoading
                  ? _EmptyChatState(persona: persona)
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          itemCount:
                              chatState.messages.length +
                              (chatState.isLoading ? 1 : 0) +
                              (chatState.error != null ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (chatState.error != null &&
                                index == chatState.messages.length) {
                              return _ErrorCard(error: chatState.error!);
                            }
                            if (index >= chatState.messages.length) {
                              return _ThinkingIndicator();
                            }
                            final message = chatState.messages[index];
                            return _ChatBubble(
                              message: message,
                              personaColor: AppColors.primary,
                            );
                          },
                        ),
                      ),
                    ),
            ),

            // Input Area
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
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
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, dynamic persona) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Hero(
                tag: 'persona_icon_${persona.id}',
                child: persona.assetImage != null
                    ? ClipOval(
                        child: Image.asset(
                          persona.assetImage,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(persona.icon, color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    persona.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Active Now',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded, size: 22),
            onPressed: () {
              ref
                  .read(chatStateProvider(personaId).notifier)
                  .startNewChat(personaId);
            },
            tooltip: 'New Chat',
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history_rounded, size: 22),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'History',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red[400],
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Service Notice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  final dynamic persona;
  const _EmptyChatState({required this.persona});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            persona.assetImage != null
                ? Container(
                    height: 120, // Larger size for empty state image
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: DecorationImage(
                        image: AssetImage(persona.assetImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : AppGlassCard(
                    borderRadius: 40,
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      persona.icon,
                      size: 50,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
            const SizedBox(height: 32),
            const Text(
              'How can I help you today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start a conversation with ${persona.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Lottie.network(
                'https://lottie.host/684c8a8c-a19c-46a4-9e32-a54190c102bd/zW7jA5v2E3.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'AI is thinking...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
    final maxBubbleWidth = screenWidth > 700 ? 550.0 : screenWidth * 0.85;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: AppGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors
                        .transparent // Changed from primary to transparent
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: isUser
                ? Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 15,
                      color:
                          AppColors.textPrimary, // Changed from white to black
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : MarkdownBody(
                    data: message.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                      h1: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      code: TextStyle(
                        backgroundColor: Colors.grey[100],
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Colors.pink[600],
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Simple Fade In animation helper
class FadeIn extends StatefulWidget {
  final Widget child;
  const FadeIn({super.key, required this.child});

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AppGlassCard(
                borderRadius: 24,
                padding: EdgeInsets.zero,
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _submit(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _submit,
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amc_persona/model/chat_session.dart';
import 'package:amc_persona/view_model/chat_view_model.dart';
import 'package:amc_persona/core/constants/persona_data.dart';
import 'package:intl/intl.dart';

class HistoryDrawer extends ConsumerWidget {
  final String personaId;

  const HistoryDrawer({super.key, required this.personaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatStateProvider(personaId));
    final history = chatState.historySessions;
    final persona = PersonaData.personas.firstWhere((p) => p.id == personaId);

    // Grouping logic
    final today = <ChatSession>[];
    final yesterday = <ChatSession>[];
    final older = <ChatSession>[];

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    for (final session in history) {
      final sDate = DateTime(
        session.timestamp.year,
        session.timestamp.month,
        session.timestamp.day,
      );
      if (sDate == todayDate) {
        today.add(session);
      } else if (sDate == yesterdayDate) {
        yesterday.add(session);
      } else {
        older.add(session);
      }
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  if (today.isNotEmpty) ...[
                    _SectionHeader(title: 'Today'),
                    ...today.map(
                      (s) => _HistoryCard(session: s, persona: persona),
                    ),
                  ],
                  if (yesterday.isNotEmpty) ...[
                    _SectionHeader(title: 'Yesterday'),
                    ...yesterday.map(
                      (s) => _HistoryCard(session: s, persona: persona),
                    ),
                  ],
                  if (older.isNotEmpty) ...[
                    _SectionHeader(title: 'Older'),
                    ...older.map(
                      (s) => _HistoryCard(session: s, persona: persona),
                    ),
                  ],
                  if (history.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          'No history yet',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  final ChatSession session;
  final dynamic persona;

  const _HistoryCard({required this.session, required this.persona});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Icon(persona.icon, size: 20, color: Colors.black87),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('HH:mm').format(session.timestamp),
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        onTap: () {
          ref
              .read(chatStateProvider(persona.id).notifier)
              .loadHistoricalSession(session);
          Navigator.pop(context); // Close drawer
        },
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 20),
          onPressed: () {
            ref
                .read(chatStateProvider(persona.id).notifier)
                .deleteHistorySession(session.id, persona.id);
          },
        ),
      ),
    );
  }
}

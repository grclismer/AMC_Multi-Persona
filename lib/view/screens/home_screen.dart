import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amc_persona/core/constants/persona_data.dart';
import 'package:amc_persona/model/persona.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Multi-Persona',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                  // fontFamily: 'Roboto', // We'll stick to default for now
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 60),
              Center(
                child: Wrap(
                  spacing: 24, // Horizontal space between cards
                  runSpacing: 40, // Vertical space between rows
                  alignment: WrapAlignment.center,
                  children: PersonaData.personas.map((persona) {
                    return _PersonaCard(persona: persona);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  final Persona persona;

  const _PersonaCard({required this.persona});

  @override
  Widget build(BuildContext context) {
    // Card dimensions based on visual estimation from the image
    const double cardSize = 150.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: cardSize,
          height: cardSize,
          child: Stack(
            clipBehavior:
                Clip.none, // Allow bubble to overflow slightly if needed
            children: [
              // Main Bordered Box - Click to view Info/Detail
              GestureDetector(
                onTap: () {
                  context.push('/persona/${persona.id}');
                },
                child: Container(
                  width: cardSize,
                  height: cardSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF64FF64), // Bright green
                      width: 5, // Thicker border
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        persona.icon,
                        size: 64,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              // Chat Bubble Icon overlay - Click to Chat directly
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    context.push('/chat/${persona.id}');
                  },
                  child: Container(
                    width: 36,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32), // Dark green
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(0), // Little tail effect
                      ),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Role Text
        GestureDetector(
          onTap: () {
            context.push('/persona/${persona.id}');
          },
          child: SizedBox(
            width: cardSize + 20, // Allow text to be slightly wider than card
            child: Text(
              persona.role,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

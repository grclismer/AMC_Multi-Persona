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
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;

                  // Adaptive column count logic
                  int crossAxisCount = 2;
                  if (availableWidth > 900) {
                    crossAxisCount = 4;
                  } else if (availableWidth > 600) {
                    crossAxisCount = 3;
                  }

                  const spacing = 24.0;
                  final cardWidth =
                      (availableWidth - (spacing * (crossAxisCount - 1))) /
                      crossAxisCount;

                  return Center(
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: 40,
                      alignment: WrapAlignment.center,
                      children: PersonaData.personas.map((persona) {
                        return _PersonaCard(
                          persona: persona,
                          cardSize: cardWidth.clamp(130.0, 180.0),
                        );
                      }).toList(),
                    ),
                  );
                },
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
  final double cardSize;

  const _PersonaCard({required this.persona, required this.cardSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: cardSize,
          height: cardSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
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
                      color: const Color(0xFF64FF64),
                      width: 5,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        persona.icon,
                        size: cardSize * 0.45, // Scale icon with card
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    context.push('/chat/${persona.id}');
                  },
                  child: Container(
                    width: 32,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            context.push('/persona/${persona.id}');
          },
          child: SizedBox(
            width: cardSize + 10,
            child: Text(
              persona.role,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
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

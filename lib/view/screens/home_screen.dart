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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Multi-Persona',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64FF64),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  double cardWidth;
                  double spacing = 12.0;
                  double runSpacing = 12.0;

                  // Premium sizing: Cards should be small and elegant
                  if (availableWidth < 450) {
                    // 📱 MOBILE: 3 columns (makes them look small/premium as requested)
                    cardWidth = (availableWidth - (spacing * 2) - 8) / 3;
                  } else if (availableWidth < 800) {
                    // 📱 MEDIUM: 3 columns
                    cardWidth = (availableWidth - (spacing * 2) - 24) / 3;
                  } else {
                    // 💻 TABLET/WIDE: 1 line (5 columns)
                    cardWidth = (availableWidth - (spacing * 4) - 48) / 5;
                  }

                  // Cap the width to ensure it doesn't look too big
                  final finalCardSize = cardWidth.clamp(90.0, 160.0);

                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: availableWidth),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: runSpacing,
                          alignment: WrapAlignment.center,
                          children: PersonaData.personas.map((persona) {
                            return _PersonaCard(
                              persona: persona,
                              cardSize: finalCardSize,
                            );
                          }).toList(),
                        ),
                      ),
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
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: cardSize,
                    height: cardSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF64FF64).withValues(alpha: 0.7),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          persona.icon,
                          size: cardSize * 0.42,
                          color: Colors.black.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: () {
                    context.push('/chat/${persona.id}');
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            context.push('/persona/${persona.id}');
          },
          child: SizedBox(
            width: cardSize + 20,
            child: Text(
              persona.role,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 2.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

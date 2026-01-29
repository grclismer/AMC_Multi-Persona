import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amc_persona/core/constants/persona_data.dart';

class PersonaDetailScreen extends StatelessWidget {
  final String personaId;

  const PersonaDetailScreen({super.key, required this.personaId});

  @override
  Widget build(BuildContext context) {
    // Find persona by ID
    final persona = PersonaData.personas.firstWhere(
      (p) => p.id == personaId,
      orElse: () => PersonaData.personas.first,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Icon Box
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF64FF64), // Bright green
                    width: 5,
                  ),
                ),
                child: Center(
                  child: Icon(persona.icon, size: 80, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              // Role Title
              Text(
                persona.role,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400, // Regular weight as per image
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 60),
              // Description / Personality
              // Note: The screenshot shows the text justified or left-aligned with specific formatting.
              // We'll wrap it in a column to handle the spacing between blocks.
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      persona.description,
                      style: const TextStyle(
                        fontSize: 14, // Small, clean font
                        color: Colors.black87,
                        height: 1.6, // Airy line height
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      persona.coreInfo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.6,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Let's Chat Button
              SizedBox(
                width:
                    200, // Not full width, looks like fixed width in screenshot
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/chat/${persona.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32), // Dark green
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        6,
                      ), // Slightly rounded
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 20),
                      SizedBox(width: 12),
                      Text(
                        "Let's Chat",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

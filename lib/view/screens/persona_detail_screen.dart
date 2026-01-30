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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            final isWide = screenWidth > 700;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? screenWidth * 0.12 : 24,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight - 64),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isWide)
                      // Tablet/Landscape Layout: Side-by-Side
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        offset: const Offset(0, 8),
                                        blurRadius: 20,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: const Color(
                                        0xFF64FF64,
                                      ).withValues(alpha: 0.8),
                                      width: 6,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      persona.icon,
                                      size: 100,
                                      color: Colors.black.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  persona.role,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  persona.description,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.black87,
                                    height: 1.7,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    persona.coreInfo,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                      height: 1.6,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      // Mobile Layout: Centered Column
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: screenWidth * 0.5,
                            height: screenWidth * 0.5,
                            constraints: const BoxConstraints(
                              maxWidth: 180,
                              maxHeight: 180,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  offset: const Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ],
                              border: Border.all(
                                color: const Color(
                                  0xFF64FF64,
                                ).withValues(alpha: 0.8),
                                width: 5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                persona.icon,
                                size: screenWidth * 0.22,
                                color: Colors.black.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            persona.role,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            persona.description,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.6,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              persona.coreInfo,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 240,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/chat/${persona.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: const Color(
                            0xFF2E7D32,
                          ).withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_rounded, size: 20),
                            SizedBox(width: 12),
                            Text(
                              "Start Conversation",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

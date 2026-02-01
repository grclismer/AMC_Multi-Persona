import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amc_persona/core/constants/persona_data.dart';
import 'package:amc_persona/core/theme/design_system.dart';
import 'package:amc_persona/view/widgets/app_branding.dart';

class PersonaDetailScreen extends StatelessWidget {
  final String personaId;

  const PersonaDetailScreen({super.key, required this.personaId});

  @override
  Widget build(BuildContext context) {
    final persona = PersonaData.personas.firstWhere(
      (p) => p.id == personaId,
      orElse: () => PersonaData.personas.first,
    );

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                persona.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final isWide = screenWidth > 700;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? screenWidth * 0.12 : 24,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          if (isWide)
                            _buildWideLayout(context, persona)
                          else
                            _buildMobileLayout(context, persona),

                          const SizedBox(height: 48),

                          // Action Button
                          _buildStartChatButton(context, persona),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, dynamic persona) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildPersonaIcon(persona, size: 200),
              const SizedBox(height: 24),
              // Name removed as it is in the header
            ],
          ),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildInfoSection(persona)],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, dynamic persona) {
    return Column(
      children: [
        _buildPersonaIcon(persona, size: 160),
        const SizedBox(height: 20),
        _buildInfoSection(persona),
      ],
    );
  }

  Widget _buildPersonaIcon(dynamic persona, {required double size}) {
    if (persona.assetImage != null) {
      return Hero(
        tag: 'persona_icon_${persona.id}',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), // Added radius
            image: DecorationImage(
              image: AssetImage(persona.assetImage!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return AppGlassCard(
      borderRadius: 32,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 4,
          ),
        ),
        child: Hero(
          tag: 'persona_icon_${persona.id}',
          child: Icon(
            persona.icon,
            size: size * 0.45,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(dynamic persona) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Persona',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          persona.description,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 32),
        AppGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  persona.coreInfo,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartChatButton(BuildContext context, dynamic persona) {
    return Container(
      width: 240,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => context.push('/chat/${persona.id}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_rounded, size: 20),
            SizedBox(width: 12),
            Text(
              "Start Chat",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

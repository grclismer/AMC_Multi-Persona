import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amc_persona/core/theme/design_system.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showHeaderCircles;

  const AppBackground({
    super.key,
    required this.child,
    this.showHeaderCircles = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient (More pronounced for mobile)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8F5E9), // Light Mint
                Colors.white,
                Color(0xFFF1F8E9), // Light Lime
              ],
            ),
          ),
        ),

        if (showHeaderCircles) ...[
          // Decorative Circles (More colorful for glass blur visibility)
          Positioned(
            top: -50,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    AppColors.primary.withOpacity(0.01),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.08),
                    AppColors.accent.withOpacity(0.01),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFFFFA000,
                ).withOpacity(0.05), // Warm secondary hit
              ),
            ),
          ),
        ],

        // Content
        child,
      ],
    );
  }
}

// Global Glass Card Widget
class AppGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: AppColors.glassBorder, width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

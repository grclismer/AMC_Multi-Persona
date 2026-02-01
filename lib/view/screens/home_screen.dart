import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amc_persona/core/constants/persona_data.dart';
import 'package:amc_persona/model/persona.dart';
import 'package:amc_persona/core/theme/design_system.dart';
import 'package:amc_persona/view/widgets/app_branding.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 200 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // PERSISTENT HEADER
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HomeHeaderDelegate(),
                ),

                // MAGNIFIED PERSONA LIST
                SliverPadding(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final isLast = index == PersonaData.personas.length;
                      return _MagnifiedPersonaCard(
                        persona: isLast ? null : PersonaData.personas[index],
                        index: index,
                        isComingSoon: isLast,
                        scrollController: _scrollController,
                      );
                    }, childCount: PersonaData.personas.length + 1),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),

            // BACK TO TOP BUTTON (Refined Size)
            if (_showBackToTop)
              Positioned(
                bottom: 30,
                right: 25,
                child: FadeIn(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: FloatingActionButton.small(
                      onPressed: _scrollToTop,
                      backgroundColor: AppColors.primary,
                      elevation: 4,
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
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

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 112; // Reduced by 3px from 115
  @override
  double get maxExtent => 240; // Compressed from 260

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = shrinkOffset / maxExtent;
    final titleProgress = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );

    return Container(
      color: Colors.white, // Solid white as requested
      child: Stack(
        alignment: Alignment.center,
        children: [
          // A M C (Fade out)
          Positioned(
            top:
                35 * (1 - titleProgress) +
                (MediaQuery.of(context).padding.top / 2),
            child: Opacity(
              opacity: (1 - progress * 3).clamp(0.0, 1.0),
              child: const Text(
                'A M C',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Multi-Persona + Underline (Sticky)
          Positioned(
            top:
                85 -
                (45 * titleProgress), // Compressed spacing (85 instead of 106)
            child: Column(
              children: [
                Text(
                  'Multi-Persona',
                  style: TextStyle(
                    fontSize: 36 - (8 * titleProgress),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10), // Reduced spacing from 12
                Container(
                  width: 60 - (20 * titleProgress),
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),

          // Journey Subtitle (Fade out)
          Positioned(
            top: 175, // Compressed spacing (175 instead of 211)
            child: Opacity(
              opacity: (1 - progress * 2.5).clamp(0.0, 1.0),
              child: const Text(
                'Choose a persona to start your journey',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) => true;
}

class _MagnifiedPersonaCard extends StatelessWidget {
  final Persona? persona;
  final int index;
  final ScrollController scrollController;
  final bool isComingSoon;

  const _MagnifiedPersonaCard({
    this.persona,
    required this.index,
    required this.scrollController,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        double scale = 0.8;

        // Dynamic Glowing Shadow Logic
        Color shadowColor = Colors.black.withOpacity(0.05);
        double blurRadius = 15.0;
        double spreadRadius = 0.0;

        if (scrollController.hasClients) {
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero).dy;
            final viewportHeight = MediaQuery.of(context).size.height;
            final center = viewportHeight / 2;

            final distanceCenter = (position + 90 - center).abs();
            scale = (1.0 - (distanceCenter / 600)).clamp(0.75, 1.0);

            // If card is near center (Medium focus), add green glow
            if (distanceCenter < 150) {
              final glowProgress = (1.0 - (distanceCenter / 150)).clamp(
                0.0,
                1.0,
              );
              shadowColor = Color.lerp(
                Colors.black.withOpacity(0.05),
                AppColors.primary.withOpacity(
                  0.5,
                ), // Clearly visible green glow
                glowProgress,
              )!;
              blurRadius = 15 + (30 * glowProgress);
              spreadRadius = 1 + (5 * glowProgress);
            }
          }
        }

        return Center(
          child: Transform.scale(
            scale: scale,
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20,
              ), // Critical for shadow visibility
              width: 340,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: blurRadius,
                    spreadRadius: spreadRadius,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isComingSoon
                  ? const _ComingSoonCard()
                  : _PersonaCard(persona: persona!, index: index),
            ),
          ),
        );
      },
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: AppGlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.lock_clock_rounded,
                size: 36,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            const Text(
              'New Persona',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Coming soon...",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
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

class _PersonaCard extends StatefulWidget {
  final Persona persona;
  final int index;

  const _PersonaCard({required this.persona, required this.index});

  @override
  State<_PersonaCard> createState() => _PersonaCardState();
}

class _PersonaCardState extends State<_PersonaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation(String route) async {
    setState(() => _isPressed = true);
    // Deliberate delay to show tap animation (Shortened from 2s to 400ms for better UX,
    // but enough to feel "premium and deliberate")
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _isPressed = false);
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              transform: (_isPressed)
                  ? (Matrix4.identity()..scale(0.92)) // Shrink on press
                  : _isHovered
                  ? (Matrix4.identity()
                      ..translate(0, -10, 0)
                      ..scale(1.02)) // Lift on hover
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.3,
                          ), // More visible glow
                          blurRadius: 30,
                          spreadRadius: 4,
                          offset: const Offset(0, 15),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: AppGlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(2), // 2px padding as requested
                child: Stack(
                  children: [
                    // Image Background
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: widget.persona.assetImage != null
                            ? Image.asset(
                                widget.persona.assetImage!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  widget.persona.icon,
                                  size: 64,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Tap handler for the card (Background tap)
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => _handleNavigation(
                            '/persona/${widget.persona.id}',
                          ),
                        ),
                      ),
                    ),

                    // Content Overlay (Placed after InkWell to allow button clicks)
                    Column(
                      children: [
                        const Spacer(),
                        // Title Centered with readable background
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              widget.persona.role,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Let's Chat Button
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () => _handleNavigation(
                                '/chat/${widget.persona.id}',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: _isHovered ? 4 : 0,
                                shadowColor: AppColors.primary.withValues(
                                  alpha: 0.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Let's Chat",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

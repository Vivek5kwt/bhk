import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              final t = _bgController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.5, 1.0],
                    colors: [
                      Color.lerp(const Color(0xFF5B8CFF), const Color(0xFF6EE7B7), t)!,
                      Color.lerp(const Color(0xFFB794F4), const Color(0xFFFF9EC4), t)!,
                      Color.lerp(const Color(0xFF60A5FA), const Color(0xFF22D3EE), 1 - t)!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Soft blurred orbs for depth
          const _BlurOrb(top: -40, left: -30, size: 220, color: Color(0xAAFFFFFF)),
          const _BlurOrb(bottom: -20, right: -30, size: 180, color: Color(0x88FFFFFF)),
          const _BlurOrb(top: 120, right: -20, size: 160, color: Color(0x66FFFFFF)),

          // Content
          SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool wide = constraints.maxWidth >= 760;
                  final double panelMaxWidth = wide ? 900 : 600;

                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: panelMaxWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: wide ? 40 : 24,
                              vertical: wide ? 32 : 24,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.black : Colors.white).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header
                                Text(
                                  'Continue as',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  semanticsLabel: 'Continue as',
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Choose your role to personalize your experience.',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: wide ? 28 : 22),

                                // Role cards
                                Flex(
                                  direction: wide ? Axis.horizontal : Axis.vertical,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: wide ? 1 : 0,
                                      child: _RoleCard(
                                        title: 'Customer',
                                        subtitle:
                                        'Book services quickly with verified profiles.',
                                        icon: Icons.person_outline,
                                        gradient: const [
                                          Color(0xFF60A5FA),
                                          Color(0xFF34D399),
                                        ],
                                        onTap: () => _goWithRole(context, 'customer'),
                                      ),
                                    ),
                                    SizedBox(width: wide ? 20 : 0, height: wide ? 0 : 16),
                                    Expanded(
                                      flex: wide ? 1 : 0,
                                      child: _RoleCard(
                                        title: 'Maid',
                                        subtitle:
                                        'Get jobs, manage bookings, and grow your work.',
                                        icon: Icons.cleaning_services_outlined,
                                        gradient: const [
                                          Color(0xFFF472B6),
                                          Color(0xFF818CF8),
                                        ],
                                        onTap: () => _goWithRole(context, 'maid'),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),
                                // Secondary actions / small print
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    _LinkText(
                                      label: 'Privacy Policy',
                                      onTap: () => _showContent(context, 'Privacy Policy'),
                                    ),
                                    _Dot(),
                                    _LinkText(
                                      label: 'Terms',
                                      onTap: () => _showContent(context, 'Terms'),
                                    ),
                                    _Dot(),
                                    _LinkText(
                                      label: 'Help',
                                      onTap: () => _showContent(context, 'Help & Support'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goWithRole(BuildContext context, String role) {
    HapticFeedback.lightImpact();
    context.go('/login?role=$role');
  }

  static const Map<String, String> _infoContent = {
    'Privacy Policy':
        'We respect your privacy and ensure your data is handled securely.',
    'Terms':
        'By using this application, you agree to abide by our terms of service.',
    'Help & Support':
        'For assistance, please contact support@example.com.',
  };

  void _showContent(BuildContext context, String title) {
    final text = _infoContent[title] ?? '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = 24.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _pressed
              ? 0.98
              : _hovering
              ? 1.02
              : 1.0,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.last.withOpacity(_hovering ? 0.35 : 0.20),
                  blurRadius: _hovering ? 28 : 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: _RoleCardContent(
              icon: widget.icon,
              title: widget.title,
              subtitle: widget.subtitle,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCardContent extends StatelessWidget {
  const _RoleCardContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon badge with subtle shine
        _ShinyBadge(
          size: isWide ? 68 : 56,
          child: Icon(icon, size: isWide ? 34 : 28, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                semanticsLabel: title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.95),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Continue',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShinyBadge extends StatelessWidget {
  const _ShinyBadge({required this.size, required this.child});
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            Colors.white,
            Color(0x80FFFFFF),
            Colors.white,
            Color(0x80FFFFFF),
            Colors.white,
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.18),
          border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('•', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white));
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
  });

  final double? top, left, right, bottom;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: (math.pi / 12),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size / 2),
            ),
          ),
        ),
      ),
    );
  }
}

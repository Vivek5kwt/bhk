import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Animated background controller
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    // Logo entrance animation (scale + fade)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale =
        CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack);
    _logoOpacity =
        CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic);

    _logoController.forward();

    // Auto navigate after 2 seconds
    _timer = Timer(const Duration(seconds: 2), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go('/walkthrough');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: GestureDetector(
        onTap: _goNext, // tap to skip
        child: Stack(
          fit: StackFit.expand,
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
                        Color.lerp(const Color(0xFF5B8CFF),
                            const Color(0xFF6EE7B7), t)!,
                        Color.lerp(const Color(0xFFF59E0B),
                            const Color(0xFFFF7AB2), t)!,
                        Color.lerp(const Color(0xFF60A5FA),
                            const Color(0xFF22D3EE), 1 - t)!,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Soft blurred orbs for depth
            const _BlurOrb(top: -40, left: -30, size: 220, opacity: .25),
            const _BlurOrb(bottom: -30, right: -10, size: 180, opacity: .18),
            const _BlurOrb(top: 120, right: -20, size: 160, opacity: .16),

            // Foreground content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: _LogoBadge(
                        iconColor: Colors.white,
                        bgColor: (isDark ? Colors.black : Colors.white)
                            .withOpacity(.12),
                        borderColor: Colors.white.withOpacity(.35),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // App name with animated shimmer-like gradient
                  _AnimatedGradientText(
                    'Bhook Lagi Hain',
                    controller: _bgController,
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: 0.95,
                    child: Text(
                      'Good food, faster.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom hint
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.9,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(.35)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: const Text(
                      'Tap to skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .2,
                      ),
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

/* -------------------- UI helpers (self-contained) -------------------- */

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
  });

  final Color iconColor;
  final Color bgColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.restaurant_rounded, color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }
}

class _AnimatedGradientText extends StatelessWidget {
  const _AnimatedGradientText(this.text, {required this.controller});
  final String text;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        final gradient = LinearGradient(
          begin: Alignment(-1 + t * 2, 0),
          end: Alignment(1 - t * 2, 0),
          colors: const [
            Colors.white70,
            Colors.white,
            Colors.white70,
          ],
          stops: const [0.2, 0.5, 0.8],
        );

        return ShaderMask(
          shaderCallback: (rect) => gradient.createShader(rect),
          child: const Text(
            'Bhook Lagi Hain',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white, // masked by shader
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        );
      },
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    this.opacity = .22,
  });

  final double? top, left, right, bottom;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                borderRadius: BorderRadius.circular(size / 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

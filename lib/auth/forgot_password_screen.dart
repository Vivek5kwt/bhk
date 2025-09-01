import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _emailNode = FocusNode();

  late final AnimationController _bg;

  @override
  void initState() {
    super.initState();
    _bg = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bg.dispose();
    _email.dispose();
    _emailNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(PasswordResetRequested(_email.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;

          return Stack(
            children: [
              // Animated gradient background
              AnimatedBuilder(
                animation: _bg,
                builder: (context, _) {
                  final t = _bg.value;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.5, 1.0],
                        colors: [
                          Color.lerp(const Color(0xFF5B8CFF), const Color(0xFF6EE7B7), t)!,
                          Color.lerp(const Color(0xFFF59E0B), const Color(0xFFFF7AB2), t)!,
                          Color.lerp(const Color(0xFF60A5FA), const Color(0xFF22D3EE), 1 - t)!,
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Soft blur blobs for depth
              const _BlurBlob(top: -40, left: -30, size: 220, opacity: .25),
              const _BlurBlob(bottom: -30, right: -10, size: 180, opacity: .18),

              // Content card
              SafeArea(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final wide = c.maxWidth >= 760;
                      final maxCardWidth = wide ? 520.0 : 420.0;

                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxCardWidth),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: wide ? 36 : 24,
                                  vertical: wide ? 32 : 24,
                                ),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: Colors.white.withOpacity(0.28)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.14),
                                      blurRadius: 26,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reset your password',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: .2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Enter your account email and we’ll send you a password reset link.',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: Colors.white.withOpacity(.92),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      _GlassField(
                                        controller: _email,
                                        focusNode: _emailNode,
                                        label: 'Email',
                                        hint: 'you@example.com',
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.done,
                                        prefix: const Icon(Icons.email_outlined, color: Colors.white),
                                        validator: (v) {
                                          final value = v?.trim() ?? '';
                                          if (value.isEmpty) return 'Email is required';
                                          final rx = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                          if (!rx.hasMatch(value)) return 'Enter a valid email';
                                          return null;
                                        },
                                        onSubmitted: (_) => _submit(context),
                                      ),

                                      const SizedBox(height: 14),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: _PrimaryAction(
                                          label: 'Send reset link',
                                          loading: loading,
                                          onPressed: loading ? null : () => _submit(context),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Tips + back to login
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        runAlignment: WrapAlignment.center,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          Text(
                                            'Didn’t receive the email? Check spam.',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.white.withOpacity(.95),
                                            ),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: loading
                                                ? null
                                                : () {
                                              if (context.canPop()) {
                                                context.pop();
                                              } else {
                                                context.go('/login');
                                              }
                                            },
                                            child: const Text(
                                              'Back to login',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
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
                    },
                  ),
                ),
              ),

              // Loading overlay
              if (loading)
                IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      color: Colors.black.withOpacity(0.18),
                      child: const Center(child: _ProgressBlur()),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/* ---------------- Reusable widgets (self-contained) ---------------- */

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.label,
    required this.hint,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(.55), width: 1),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: keyboardType == TextInputType.emailAddress
          ? const [AutofillHints.email]
          : null,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        labelStyle: TextStyle(color: Colors.white.withOpacity(.95)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(.65)),
        filled: true,
        fillColor: Colors.white.withOpacity(.10),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.white, width: 1.4),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      ),
    );
  }
}

class _PrimaryAction extends StatefulWidget {
  const _PrimaryAction({
    required this.label,
    required this.onPressed,
    required this.loading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  State<_PrimaryAction> createState() => _PrimaryActionState();
}

class _PrimaryActionState extends State<_PrimaryAction> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = _down ? 0.98 : _hover ? 1.01 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _down = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: scale,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(.25),
            ),
            onPressed: widget.onPressed,
            child: widget.loading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.mark_email_read_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Send reset link',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: .3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({
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
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(size / 2),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: const SizedBox(),
          ),
        ),
      ),
    );
  }
}

class _ProgressBlur extends StatelessWidget {
  const _ProgressBlur();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.25),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(.35)),
          ),
          child: const SizedBox(
            height: 36,
            width: 36,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}

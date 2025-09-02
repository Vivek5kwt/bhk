import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailNode = FocusNode();
  final _passwordNode = FocusNode();

  bool _obscure = true;
  bool _rememberMe = true;

  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _email.dispose();
    _password.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, String? role) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(
      LoginRequested(_email.text.trim(), _password.text, role),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Read role from query (?role=customer|maid) to customize copy
    final role =
    GoRouterState.of(context).uri.queryParameters['role']?.toLowerCase();
    final roleLabel = switch (role) {
      'customer' => 'Customer',
      'maid' => 'Maid',
      _ => 'There',
    };

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            context.go('/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is PhoneCodeSent) {
            context.go('/otp', extra: state.confirmationResult);
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;

          return Stack(
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
                          Color.lerp(const Color(0xFFF59E0B), const Color(0xFFFF7AB2), t)!,
                          Color.lerp(const Color(0xFF60A5FA), const Color(0xFF22D3EE), 1 - t)!,
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Subtle blurred blobs for depth
              const _BlurBlob(top: -30, left: -20, size: 220, opacity: .25),
              const _BlurBlob(bottom: -30, right: -10, size: 180, opacity: .18),

              // Form card
              SafeArea(
                child: Center(
                  child: LayoutBuilder(builder: (context, c) {
                    final wide = c.maxWidth >= 760;
                    final maxCardWidth = wide ? 520.0 : 420.0;

                    return ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxCardWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
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
                                color:
                                (isDark ? Colors.black : Colors.white)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.28),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.14),
                                    blurRadius: 26,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    // Greeting / Title
                                    Text(
                                      roleLabel == 'There'
                                          ? 'Welcome back'
                                          : 'Welcome, $roleLabel',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: .2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      roleLabel == 'Customer'
                                          ? 'Sign in to book trusted services quickly.'
                                          : roleLabel == 'Maid'
                                          ? 'Sign in to manage jobs and grow your work.'
                                          : 'Sign in to continue.',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                        color: Colors.white.withOpacity(.92),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Email
                                    _GlassField(
                                      controller: _email,
                                      focusNode: _emailNode,
                                      label: 'Email',
                                      hint: 'you@example.com',
                                      keyboardType:
                                      TextInputType.emailAddress,
                                      textInputAction:
                                      TextInputAction.next,
                                      prefix: const Icon(
                                          Icons.email_outlined,
                                          color: Colors.white),
                                      validator: (v) {
                                        final value = v?.trim() ?? '';
                                        if (value.isEmpty) {
                                          return 'Email is required';
                                        }
                                        final emailRx = RegExp(
                                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                        if (!emailRx.hasMatch(value)) {
                                          return 'Enter a valid email';
                                        }
                                        return null;
                                      },
                                      onSubmitted: (_) =>
                                          _passwordNode.requestFocus(),
                                    ),
                                    const SizedBox(height: 12),

                                    // Password
                                    _GlassField(
                                      controller: _password,
                                      focusNode: _passwordNode,
                                      label: 'Password',
                                      hint: '********',
                                      obscure: _obscure,
                                      prefix: const Icon(
                                          Icons.lock_outline,
                                          color: Colors.white),
                                      suffix: IconButton(
                                        tooltip: _obscure
                                            ? 'Show'
                                            : 'Hide',
                                        icon: Icon(
                                          _obscure
                                              ? Icons
                                              .visibility_outlined
                                              : Icons
                                              .visibility_off_outlined,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => setState(
                                                () => _obscure = !_obscure),
                                      ),
                                      validator: (v) {
                                        if ((v ?? '').isEmpty) {
                                          return 'Password is required';
                                        }
                                        if ((v ?? '').length < 6) {
                                          return 'Must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      onSubmitted: (_) =>
                                          _submit(context, role),
                                    ),

                                    const SizedBox(height: 8),

                                    // Remember + Forgot  (fixed for small widths)
                                    Row(
                                      children: [
                                        // Left cluster expands and can wrap text safely
                                        Expanded(
                                          child: Wrap(
                                            spacing: 8,
                                            crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                            children: [
                                              Checkbox(
                                                value: _rememberMe,
                                                onChanged: loading
                                                    ? null
                                                    : (v) => setState(() =>
                                                _rememberMe =
                                                    v ?? true),
                                                side: const BorderSide(
                                                    color: Colors.white),
                                                checkColor: Colors.black,
                                                activeColor: Colors.white,
                                                materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                              ),
                                              const SizedBox(width: 2),
                                              // This text can ellipsize to prevent overflow
                                              const _RememberText(),
                                            ],
                                          ),
                                        ),
                                        // Right action shrinks gracefully
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 8),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                            ),
                                            onPressed: loading
                                                ? null
                                                : () =>
                                                context.push('/forgot'),
                                            child: const Text(
                                              'Forgot password?',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Primary button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: _PrimaryAction(
                                        loading: loading,
                                        label: 'Sign in',
                                        onPressed: loading
                                            ? null
                                            : () => _submit(context, role),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Divider
                                    Row(
                                      children: [
                                        const Expanded(
                                            child: _DividerLine()),
                                        Padding(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            'or continue with',
                                            style: theme
                                                .textTheme.labelLarge
                                                ?.copyWith(
                                              color: Colors.white
                                                  .withOpacity(.9),
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                            child: _DividerLine()),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Social buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _SocialButton(
                                            label: 'Google',
                                            icon: Icons
                                                .g_mobiledata_rounded,
                                            onTap: loading
                                                ? null
                                                : () => context
                                                .read<AuthBloc>()
                                                .add(
                                                GoogleLoginRequested()),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _SocialButton(
                                            label: 'Facebook',
                                            icon:
                                            Icons.facebook_rounded,
                                            onTap: loading
                                                ? null
                                                : () => context
                                                .read<AuthBloc>()
                                                .add(
                                                FacebookLoginRequested()),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // Phone
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        style:
                                        OutlinedButton.styleFrom(
                                          foregroundColor:
                                          Colors.white,
                                          side: BorderSide(
                                            color: Colors.white
                                                .withOpacity(.7),
                                          ),
                                          padding: const EdgeInsets
                                              .symmetric(
                                              vertical: 14,
                                              horizontal: 14),
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                14),
                                          ),
                                        ),
                                        onPressed: loading
                                            ? null
                                            : () => context.go('/phone'),
                                        icon: const Icon(Icons
                                            .phone_iphone_rounded),
                                        label: const Text(
                                            'Continue with phone'),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Bottom prompt  (fixed using Wrap)
                                    Center(
                                      child: Wrap(
                                        alignment:
                                        WrapAlignment.center,
                                        spacing: 4,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            "Don't have an account?",
                                            style: theme
                                                .textTheme.bodyMedium
                                                ?.copyWith(
                                              color: Colors.white
                                                  .withOpacity(.95),
                                            ),
                                          ),
                                          TextButton(
                                            style:
                                            TextButton.styleFrom(
                                              padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  8,
                                                  vertical:
                                                  6),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                            ),
                                            onPressed: loading
                                                ? null
                                                : () => context.push(
                                                    '/signup${role != null ? '?role=$role' : ''}'),
                                            child: const Text(
                                              'Create account',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Loading overlay
              if (loading)
                IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration:
                    const Duration(milliseconds: 200),
                    child: Container(
                      color: Colors.black.withOpacity(0.18),
                      child: const Center(
                        child: _ProgressBlur(),
                      ),
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

/* ---------- Small UI helpers ---------- */

class _RememberText extends StatelessWidget {
  const _RememberText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Remember me',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

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
          : const [AutofillHints.password],
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
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
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
    final scale = _down
        ? 0.98
        : _hover
        ? 1.01
        : 1.0;

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
                Icon(Icons.login_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Sign in',
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(.2),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.7),
            Colors.white.withOpacity(0.0),
          ],
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
          child:  BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: SizedBox(),
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

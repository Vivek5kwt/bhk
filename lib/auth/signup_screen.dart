import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _emailNode = FocusNode();
  final _passwordNode = FocusNode();
  final _confirmNode = FocusNode();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _agree = true;

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
    _password.dispose();
    _confirm.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    _confirmNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms & Privacy.')),
      );
      return;
    }
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(
      SignupRequested(_email.text.trim(), _password.text),
    );
  }

  int _passwordScore(String v) {
    int score = 0;
    if (v.length >= 6) score++;
    if (v.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[^\w\s]').hasMatch(v)) score++;
    return score.clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role =
    GoRouterState.of(context).uri.queryParameters['role']?.toLowerCase();
    final roleLabel = switch (role) {
      'customer' => 'Customer',
      'maid' => 'Maid',
      _ => null,
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            // Optional: navigate after successful registration
            // context.go('/login');
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

              // Soft blur blobs
              const _BlurBlob(top: -40, left: -30, size: 220, opacity: .25),
              const _BlurBlob(bottom: -30, right: -10, size: 180, opacity: .18),

              SafeArea(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, c) {
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
                              child: Container
                                (
                                padding: EdgeInsets.symmetric(
                                  horizontal: wide ? 36 : 24,
                                  vertical: wide ? 32 : 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.28)),
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        roleLabel == null
                                            ? 'Create account'
                                            : 'Join as $roleLabel',
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
                                            ? 'Book trusted services faster with your account.'
                                            : roleLabel == 'Maid'
                                            ? 'Start getting jobs and manage bookings with ease.'
                                            : 'Sign up to continue.',
                                        style:
                                        theme.textTheme.bodyLarge?.copyWith(
                                          color:
                                          Colors.white.withOpacity(.92),
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
                                        textInputAction: TextInputAction.next,
                                        prefix: const Icon(
                                          Icons.email_outlined,
                                          color: Colors.white,
                                        ),
                                        validator: (v) {
                                          final value = v?.trim() ?? '';
                                          if (value.isEmpty) {
                                            return 'Email is required';
                                          }
                                          final rx = RegExp(
                                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                          if (!rx.hasMatch(value)) {
                                            return 'Enter a valid email';
                                          }
                                          return null;
                                        },
                                        onSubmitted: (_) =>
                                            _passwordNode.requestFocus(),
                                      ),
                                      const SizedBox(height: 12),

                                      // Password
                                      StatefulBuilder(
                                        builder: (context, setSB) {
                                          final score =
                                          _passwordScore(_password.text);
                                          return Column(
                                            children: [
                                              _GlassField(
                                                controller: _password,
                                                focusNode: _passwordNode,
                                                label: 'Password',
                                                hint: 'Min 6 characters',
                                                obscure: _obscure1,
                                                prefix: const Icon(
                                                  Icons.lock_outline,
                                                  color: Colors.white,
                                                ),
                                                suffix: IconButton(
                                                  tooltip: _obscure1
                                                      ? 'Show'
                                                      : 'Hide',
                                                  icon: Icon(
                                                    _obscure1
                                                        ? Icons
                                                        .visibility_outlined
                                                        : Icons
                                                        .visibility_off_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () => setSB(() =>
                                                  _obscure1 = !_obscure1),
                                                ),
                                                onChanged: (_) => setSB(() {}),
                                                validator: (v) {
                                                  final value = v ?? '';
                                                  if (value.isEmpty) {
                                                    return 'Password is required';
                                                  }
                                                  if (value.length < 6) {
                                                    return 'Must be at least 6 characters';
                                                  }
                                                  return null;
                                                },
                                                onSubmitted: (_) =>
                                                    _confirmNode
                                                        .requestFocus(),
                                              ),
                                              const SizedBox(height: 8),
                                              _PasswordStrengthBar(score: score),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),

                                      // Confirm password
                                      _GlassField(
                                        controller: _confirm,
                                        focusNode: _confirmNode,
                                        label: 'Confirm password',
                                        hint: 'Re-enter password',
                                        obscure: _obscure2,
                                        prefix: const Icon(
                                          Icons.verified_user_outlined,
                                          color: Colors.white,
                                        ),
                                        suffix: IconButton(
                                          tooltip:
                                          _obscure2 ? 'Show' : 'Hide',
                                          icon: Icon(
                                            _obscure2
                                                ? Icons.visibility_outlined
                                                : Icons
                                                .visibility_off_outlined,
                                            color: Colors.white,
                                          ),
                                          onPressed: () => setState(
                                                  () => _obscure2 = !_obscure2),
                                        ),
                                        validator: (v) {
                                          if ((v ?? '').isEmpty) {
                                            return 'Please confirm password';
                                          }
                                          if (v != _password.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                        onSubmitted: (_) => _submit(context),
                                      ),

                                      const SizedBox(height: 10),

                                      // Terms
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _agree,
                                            onChanged: loading
                                                ? null
                                                : (val) => setState(
                                                    () => _agree =
                                                    val ?? false),
                                            side: const BorderSide(
                                                color: Colors.white),
                                            checkColor: Colors.black,
                                            activeColor: Colors.white,
                                          ),
                                          Flexible(
                                            child: Wrap(
                                              crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  'I agree to the ',
                                                  style: theme
                                                      .textTheme.labelLarge
                                                      ?.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                _LinkText(
                                                  label: 'Terms',
                                                  onTap: () =>
                                                      _toast(context, 'Terms'),
                                                ),
                                                Text(
                                                  ' and ',
                                                  style: theme
                                                      .textTheme.labelLarge
                                                      ?.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                _LinkText(
                                                  label: 'Privacy Policy',
                                                  onTap: () => _toast(context,
                                                      'Privacy Policy'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Sign up
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: _PrimaryAction(
                                          label: 'Create account',
                                          loading: loading,
                                          onPressed: loading
                                              ? null
                                              : () => _submit(context),
                                        ),
                                      ),

                                      const SizedBox(height: 14),

                                      // Divider + back to login
                                      Row(
                                        children: [
                                          const Expanded(child: _DividerLine()),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              'Already have an account?',
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                color: Colors.white
                                                    .withOpacity(.9),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const Expanded(child: _DividerLine()),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            side: BorderSide(
                                              color: Colors.white
                                                  .withOpacity(.7),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14, horizontal: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(14),
                                            ),
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
                                          icon: const Icon(
                                              Icons.login_rounded),
                                          label: const Text('Back to login'),
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

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/* ------------ UI helpers (self-contained) ------------ */

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
    this.onChanged,
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
  final void Function(String)? onChanged;

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
          : const [AutofillHints.newPassword],
      style: const TextStyle(color: Colors.white),
      validator: validator,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
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
              children: [
                const Icon(Icons.person_add_alt_1_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
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

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.score});
  final int score;

  String get _label => switch (score) {
    0 || 1 => 'Weak',
    2 => 'Fair',
    3 => 'Good',
    _ => 'Strong',
  };

  double get _value => (score / 5).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.redAccent,
      Colors.orange,
      Colors.amber,
      Colors.lightGreen,
      Colors.green,
    ];
    final color = colors[(score.clamp(0, 4))];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: _value,
            color: color,
            backgroundColor: Colors.white.withOpacity(.25),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Password strength: $_label',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

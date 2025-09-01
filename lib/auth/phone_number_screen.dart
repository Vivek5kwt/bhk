import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _phoneNode = FocusNode();

  // Lightweight dial code list (add more if you like, no extra packages needed)
  final List<String> _dialCodes = const ['+91', '+1', '+44', '+61', '+971', '+81', '+49'];
  String _dialCode = '+91';

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
    _phone.dispose();
    _phoneNode.dispose();
    super.dispose();
  }

  void _sendOtp(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final raw = _phone.text.replaceAll(RegExp(r'\D'), '');
    final e164 = '$_dialCode$raw';
    context.read<AuthBloc>().add(PhoneLoginRequested(e164));
  }

  // Validates common E.164 patterns, with a friendlier India rule when +91
  String? _validatePhone(String? v) {
    final raw = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (raw.isEmpty) return 'Phone number is required';

    if (_dialCode == '+91') {
      if (raw.length != 10) return 'Enter 10-digit mobile number';
      if (!RegExp(r'^[6-9]').hasMatch(raw)) {
        return 'Indian numbers start with 6-9';
      }
    } else {
      // E.164 max 15 digits; require at least 7 local digits for non-IN
      if (raw.length < 7 || raw.length > 15) {
        return 'Enter a valid phone number';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Optional personalization like other screens
    final role = GoRouterState.of(context).uri.queryParameters['role']?.toLowerCase();
    final roleLabel = switch (role) {
      'customer' => 'Customer',
      'maid' => 'Maid',
      _ => null,
    };

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Phone Login', style: TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PhoneCodeSent) {
            context.go('/otp', extra: state.confirmationResult);
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

              // Card
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
                                        roleLabel == null
                                            ? 'Verify your phone'
                                            : 'Verify your phone, $roleLabel',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: .2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'We\'ll send a one-time code to your number.',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: Colors.white.withOpacity(.92),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Phone field (dial code + number) — fully responsive
                                      _PhoneField(
                                        dialCodes: _dialCodes,
                                        dialCode: _dialCode,
                                        onDialChanged: (v) => setState(() => _dialCode = v),
                                        controller: _phone,
                                        focusNode: _phoneNode,
                                        validator: _validatePhone,
                                        enabled: !loading,
                                        hint: _dialCode == '+91' ? '98765 43210' : 'Phone number',
                                      ),

                                      const SizedBox(height: 14),

                                      // Send OTP button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: _PrimaryAction(
                                          label: 'Send OTP',
                                          loading: loading,
                                          onPressed: loading ? null : () => _sendOtp(context),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Secondary: use email/password instead
                                      Center(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              'Prefer email instead?',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Colors.white.withOpacity(.95),
                                              ),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              onPressed: loading ? null : () => context.go('/login'),
                                              child: const Text(
                                                'Sign in with password',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
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

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.dialCodes,
    required this.dialCode,
    required this.onDialChanged,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.enabled,
    required this.hint,
  });

  final List<String> dialCodes;
  final String dialCode;
  final ValueChanged<String> onDialChanged;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String> validator;
  final bool enabled;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(.55), width: 1),
    );

    return Row(
      children: [
        // Dial code dropdown
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 110, maxWidth: 140),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Code',
              labelStyle: TextStyle(color: Colors.white.withOpacity(.95)),
              filled: true,
              fillColor: Colors.white.withOpacity(.10),
              enabledBorder: baseBorder,
              focusedBorder: baseBorder.copyWith(
                borderSide: const BorderSide(color: Colors.white, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dialCode,
                isDense: true,
                iconEnabledColor: Colors.white,
                dropdownColor: Colors.black87,
                items: dialCodes
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, style: const TextStyle(color: Colors.white)),
                ))
                    .toList(),
                // FIX: wrap non-nullable handler to accept nullable String?
                onChanged: enabled
                    ? (String? v) {
                  if (v != null) onDialChanged(v);
                }
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Phone number field (digits only)
        Expanded(
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            style: const TextStyle(color: Colors.white),
            validator: validator,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              labelText: 'Phone number',
              hintText: hint,
              prefixIcon: const Icon(Icons.phone_iphone_rounded, color: Colors.white),
              labelStyle: TextStyle(color: Colors.white.withOpacity(.95)),
              hintStyle: TextStyle(color: Colors.white.withOpacity(.65)),
              filled: true,
              fillColor: Colors.white.withOpacity(.10),
              enabledBorder: baseBorder,
              focusedBorder: baseBorder.copyWith(
                borderSide: const BorderSide(color: Colors.white, width: 1.4),
              ),
              errorBorder: baseBorder.copyWith(
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
              ),
              focusedErrorBorder: baseBorder.copyWith(
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            ),
          ),
        ),
      ],
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
                Icon(Icons.sms_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Send OTP',
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

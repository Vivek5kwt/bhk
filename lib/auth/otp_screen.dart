import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final dynamic confirmationResult;
  const OtpScreen({super.key, required this.confirmationResult});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  // Hidden input that drives the 6 code boxes
  final TextEditingController _otp = TextEditingController();
  final FocusNode _otpNode = FocusNode();

  late final AnimationController _bg;
  Timer? _timer;
  int _seconds = 60; // resend countdown

  @override
  void initState() {
    super.initState();
    _bg = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..repeat(reverse: true);

    // Start countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) return t.cancel();
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bg.dispose();
    _otp.dispose();
    _otpNode.dispose();
    super.dispose();
  }

  String get _code {
    final digits = _otp.text.replaceAll(RegExp(r'\D'), '');
    return digits.length > 6 ? digits.substring(0, 6) : digits;
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final raw = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (raw.isEmpty) return;
    setState(() => _otp.text = raw.length > 6 ? raw.substring(0, 6) : raw);
  }

  void _verify(BuildContext context) {
    final code = _code;
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }
    HapticFeedback.lightImpact();
    context
        .read<AuthBloc>()
        .add(VerifyPhoneCodeRequested(widget.confirmationResult, code));
  }

  @override
  Widget build(BuildContext context) {
    // Optional personalization like your other screens
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
        title: const Text('Verify OTP', style: TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            context.go('/home');
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      roleLabel == null
                                          ? 'Enter the 6-digit code'
                                          : 'Enter the 6-digit code, $roleLabel',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: .2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'We’ve sent an SMS with a verification code.',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.white.withOpacity(.92),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // OTP boxes + hidden input
                                    _OtpBoxes(
                                      code: _code,
                                      focusNode: _otpNode,
                                      onTap: () => FocusScope.of(context).requestFocus(_otpNode),
                                    ),
                                    // Hidden real input
                                    Offstage(
                                      offstage: false,
                                      child: TextField(
                                        controller: _otp,
                                        focusNode: _otpNode,
                                        autofocus: true,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(6),
                                        ],
                                        // Keep text invisible but editable
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        cursorColor: Colors.transparent,
                                        style: const TextStyle(color: Colors.transparent),
                                        onChanged: (_) => setState(() {}),
                                        onSubmitted: (_) => _verify(context),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Actions row: countdown + paste + change number
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      runAlignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 10,
                                      runSpacing: 8,
                                      children: [
                                        _CountdownLabel(seconds: _seconds),
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: loading ? null : _pasteFromClipboard,
                                          icon: const Icon(Icons.content_paste, color: Colors.white),
                                          label: const Text('Paste code',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: loading ? null : () => context.go('/phone'),
                                          child: const Text('Change number',
                                              style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Verify button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: _PrimaryAction(
                                        label: 'Verify',
                                        loading: loading,
                                        onPressed: (_code.length == 6 && !loading)
                                            ? () => _verify(context)
                                            : null,
                                      ),
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

/* ------------------- UI pieces (self-contained) ------------------- */

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.code,
    required this.focusNode,
    required this.onTap,
  });

  final String code;
  final FocusNode focusNode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final digits = List<String>.generate(6, (i) => i < code.length ? code[i] : '');
    final isFocused = focusNode.hasFocus;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (i) {
          final filled = digits[i].isNotEmpty;
          final active = isFocused && (i == code.length || (code.length == 6 && i == 5));

          return _OtpCell(
            value: digits[i],
            active: active,
            filled: filled,
          );
        }),
      ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({required this.value, required this.active, required this.filled});

  final String value;
  final bool active;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white.withOpacity(.10);
    final border = active ? Colors.white : Colors.white.withOpacity(.55);
    final shadow = filled ? Colors.black.withOpacity(.20) : Colors.transparent;

    return Container(
      width: 46,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: active ? 1.6 : 1.0),
        boxShadow: [BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CountdownLabel extends StatelessWidget {
  const _CountdownLabel({required this.seconds});
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final mm = (seconds ~/ 60).toString().padLeft(1, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return Text(
      seconds > 0 ? 'Resend in $mm:$ss' : 'You can request a new code',
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
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
              children: [
                const Icon(Icons.verified_rounded, size: 20),
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

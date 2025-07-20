import 'package:flutter/material.dart';
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

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Login')),
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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(PhoneLoginRequested(_phoneController.text));
                  },
                  child: state is AuthLoading
                      ? const CircularProgressIndicator()
                      : const Text('Send OTP'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

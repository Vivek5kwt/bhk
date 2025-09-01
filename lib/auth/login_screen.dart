import 'package:flutter/material.dart';
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

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.login,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          LoginRequested(
                            _emailController.text,
                            _passwordController.text,
                          ),
                        );
                  },
                  child: state is AuthLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(GoogleLoginRequested());
                  },
                  child: const Text('Login with Google'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(FacebookLoginRequested());
                  },
                  child: const Text('Login with Facebook'),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/phone'),
                  child: const Text('Continue with phone'),
                ),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: const Text('Create account'),
                ),
                TextButton(
                  onPressed: () => context.push('/forgot'),
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

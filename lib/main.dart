import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/phone_number_screen.dart';
import 'auth/otp_screen.dart';
import 'auth/bloc/auth_bloc.dart';
import 'api/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/walkthrough_screen.dart';
import 'screens/home_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/help_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/walkthrough', builder: (_, __) => const WalkthroughScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/phone', builder: (_, __) => const PhoneNumberScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(confirmationResult: state.extra),
      ),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsScreen()),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacyScreen()),
      GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(AuthService()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Bhook Lagi Hain',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}

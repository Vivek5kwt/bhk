import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WalkthroughScreen extends StatelessWidget {
  const WalkthroughScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Continue as:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('As a Customer'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('As a Maid'),
            ),
          ],
        ),
      ),
    );
  }
}

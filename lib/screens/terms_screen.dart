import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'These are the terms and conditions of the app. Users must agree to them before continuing.',
        ),
      ),
    );
  }
}

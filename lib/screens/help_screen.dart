import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'For help, please contact support or consult the FAQ section.',
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: const Text('Logout'),
          leading: const Icon(Icons.logout),
          onTap: () {
            context.read<AuthBloc>().add(LogoutRequested());
          },
        ),
        ListTile(
          title: const Text('Delete Account'),
          leading: const Icon(Icons.delete_forever),
          onTap: () {
            context.read<AuthBloc>().add(DeleteAccountRequested());
          },
        ),
      ],
    );
  }
}

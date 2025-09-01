import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../info/info_cubit.dart';
import '../info/info_state.dart';

class InfoScreen extends StatelessWidget {
  final InfoPage page;
  const InfoScreen({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InfoCubit()..load(page),
      child: Scaffold(
        appBar: AppBar(title: Text(_titleForPage(page))),
        body: BlocBuilder<InfoCubit, InfoState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(state.content ?? ''),
            );
          },
        ),
      ),
    );
  }

  String _titleForPage(InfoPage page) {
    switch (page) {
      case InfoPage.terms:
        return 'Terms & Conditions';
      case InfoPage.privacy:
        return 'Privacy Policy';
      case InfoPage.help:
        return 'Help';
    }
  }
}

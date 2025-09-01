import 'package:bloc/bloc.dart';
import 'info_state.dart';

enum InfoPage { terms, privacy, help }

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(const InfoState());

  Future<void> load(InfoPage page) async {
    emit(state.copyWith(loading: true, content: null, error: null));
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final content = _contentForPage(page);
      emit(InfoState(content: content));
    } catch (e) {
      emit(InfoState(error: e.toString()));
    }
  }

  String _contentForPage(InfoPage page) {
    switch (page) {
      case InfoPage.terms:
        return 'These are the terms and conditions of the app.'
            ' Users must agree to them before continuing.';
      case InfoPage.privacy:
        return 'This privacy policy explains how user data is handled'
            ' and stored securely.';
      case InfoPage.help:
        return 'For help, please contact support or consult the FAQ section.';
    }
  }
}

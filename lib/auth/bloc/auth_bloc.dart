import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<SignupRequested>(_onSignup);
    on<PasswordResetRequested>(_onReset);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    if (event.email.isNotEmpty && event.password.isNotEmpty) {
      emit(AuthSuccess('Logged in as ${event.email}'));
    } else {
      emit(AuthFailure('Email and password required'));
    }
  }

  Future<void> _onSignup(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    if (event.email.isNotEmpty && event.password.isNotEmpty) {
      emit(AuthSuccess('Account created for ${event.email}'));
    } else {
      emit(AuthFailure('Email and password required'));
    }
  }

  Future<void> _onReset(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    if (event.email.isNotEmpty) {
      emit(AuthSuccess('Password reset link sent to ${event.email}'));
    } else {
      emit(AuthFailure('Email required'));
    }
  }
}

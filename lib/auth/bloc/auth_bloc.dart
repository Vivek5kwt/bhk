import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../api/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._service) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<SignupRequested>(_onSignup);
    on<PasswordResetRequested>(_onReset);
    on<LogoutRequested>(_onLogout);
    on<DeleteAccountRequested>(_onDelete);
    on<GoogleLoginRequested>(_onGoogleLogin);
    on<FacebookLoginRequested>(_onFacebookLogin);
    on<PhoneLoginRequested>(_onPhoneLogin);
    on<VerifyPhoneCodeRequested>(_onVerifyPhoneCode);
  }

  final AuthService _service;

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await _service.login(event.email, event.password);
      emit(AuthSuccess(message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignup(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await _service.signup(event.email, event.password);
      emit(AuthSuccess(message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onReset(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await _service.resetPassword(event.email);
      emit(AuthSuccess(message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await _service.logout();
      emit(AuthSuccess(message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await _service.deleteAccount();
      emit(AuthSuccess(message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onGoogleLogin(GoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await _service.loginWithGoogle();
      emit(AuthSuccess(message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onFacebookLogin(FacebookLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await _service.loginWithFacebook();
      emit(AuthSuccess(message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onPhoneLogin(PhoneLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _service.loginWithPhone(event.phoneNumber);
      emit(PhoneCodeSent(result));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onVerifyPhoneCode(VerifyPhoneCodeRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await _service.verifyPhoneCode(event.confirmationResult, event.smsCode);
      emit(AuthSuccess(message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}

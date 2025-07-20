abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  SignupRequested(this.email, this.password);
}

class PasswordResetRequested extends AuthEvent {
  final String email;
  PasswordResetRequested(this.email);
}

class GoogleLoginRequested extends AuthEvent {}

class FacebookLoginRequested extends AuthEvent {}

class PhoneLoginRequested extends AuthEvent {
  final String phoneNumber;
  PhoneLoginRequested(this.phoneNumber);
}

class VerifyPhoneCodeRequested extends AuthEvent {
  final dynamic confirmationResult;
  final String smsCode;
  VerifyPhoneCodeRequested(this.confirmationResult, this.smsCode);
}

class LogoutRequested extends AuthEvent {}

class DeleteAccountRequested extends AuthEvent {}

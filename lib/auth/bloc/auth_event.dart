abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? role;
  LoginRequested(this.email, this.password, this.role);
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String? role;
  SignupRequested(this.email, this.password, this.role);
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

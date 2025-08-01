import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  Future<String> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return 'Login successful';
  }

  Future<String> signup(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return 'Signup successful';
  }

  Future<String> loginWithGoogle() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google sign in aborted');
    }
    final GoogleSignInAuthentication auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    await _auth.signInWithCredential(credential);
    return 'Google sign in successful';
  }

  Future<String> loginWithFacebook() async {
    final LoginResult result = await _facebookAuth.login();
    if (result.status != LoginStatus.success) {
      throw Exception('Facebook sign in failed');
    }
    final OAuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken!.token);
    await _auth.signInWithCredential(credential);
    return 'Facebook sign in successful';
  }

  Future<ConfirmationResult> loginWithPhone(String phoneNumber) {
    return _auth.signInWithPhoneNumber(phoneNumber);
  }

  Future<String> verifyPhoneCode(
      ConfirmationResult result, String smsCode) async {
    await result.confirm(smsCode);
    return 'Phone sign in successful';
  }

  Future<String> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    return 'Reset email sent';
  }

  Future<String> logout() async {
    await _auth.signOut();
    return 'Logged out';
  }

  Future<String> deleteAccount() async {
    await _auth.currentUser?.delete();
    return 'Account deleted';
  }
}

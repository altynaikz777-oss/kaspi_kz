import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';

class AuthService {
  AuthService(this._auth, {GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: const ['email', 'profile'],
            clientId: kIsWeb ? DefaultFirebaseOptions.googleWebClientId : null,
            serverClientId: kIsWeb
                ? null
                : DefaultFirebaseOptions.googleWebClientId,
          );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  ConfirmationResult? _webConfirmationResult;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  /// Returns [UserCredential] on success, or null if the user cancelled the flow.
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});
      return _auth.signInWithPopup(provider);
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      return null;
    }

    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> startPhoneSignIn({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
  }) async {
    if (kIsWeb) {
      try {
        _webConfirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
        onCodeSent('', null);
      } on FirebaseAuthException catch (error) {
        onError(error);
      }
      return;
    }

    final completer = Completer<void>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        onAutoVerified(credential);
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      verificationFailed: (error) {
        onError(error);
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId, resendToken);
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeAutoRetrievalTimeout: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );
    await completer.future;
  }

  Future<UserCredential> verifyOtp({
    required String smsCode,
    String? verificationId,
  }) async {
    if (kIsWeb) {
      final result = _webConfirmationResult;
      if (result == null) {
        throw FirebaseAuthException(
          code: 'missing-confirmation',
          message: 'Сначала запросите код доступа.',
        );
      }
      return result.confirm(smsCode);
    }

    if (verificationId == null || verificationId.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-verification-id',
        message: 'Не удалось получить идентификатор подтверждения.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }
}

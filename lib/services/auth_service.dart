// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/services.dart'; 

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthResult {
  final UserCredential? credential;
  final String? errorMessage;
  final bool success;

  AuthResult({this.credential, this.errorMessage, required this.success});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // This line is throwing the PlatformException
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResult(credential: credential, success: true);
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific exceptions
      String message;
      if (e.code == 'invalid-credential') {
        message =
            'Invalid email or password. Please check your credentials and try again.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled. Please contact support.';
      } else if (e.code == 'user-not-found') {
        message = 'No account found with this email. Please sign up first.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else {
        message = 'Authentication error: ${e.message}';
      }

      return AuthResult(success: false, errorMessage: message);
    } on PlatformException catch (e) {
      // Add explicit handling for PlatformException
      return AuthResult(
        success: false,
        errorMessage: 'Authentication error: ${e.message}',
      );
    } catch (e) {
      // Handle any other exceptions
      return AuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}

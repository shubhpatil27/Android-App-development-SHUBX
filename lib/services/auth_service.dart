import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance =
  AuthService._();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  User? get currentUser =>
      _auth.currentUser;

  bool get isSignedIn =>
      currentUser != null;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // ==================================================
  // CREATE ACCOUNT
  // ==================================================

  Future<UserCredential> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail =
    email.trim().toLowerCase();

    final credential =
    await _auth
        .createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception(
        'Could not create user.',
      );
    }

    try {
      await user.updateDisplayName(
        name.trim(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': name.trim(),
        'email': normalizedEmail,
        'createdAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      try {
        await user.sendEmailVerification();
      } catch (_) {
        // Account creation should not fail simply
        // because verification email could not send.
      }

      return credential;
    } catch (error) {
      try {
        await user.delete();
      } catch (_) {}

      rethrow;
    }
  }

  // ==================================================
  // SIGN IN
  // ==================================================

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  // ==================================================
  // PASSWORD RESET
  // ==================================================

  Future<void> sendPasswordReset({
    required String email,
  }) {
    return _auth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  // ==================================================
  // EMAIL VERIFICATION
  // ==================================================

  Future<void>
  resendVerificationEmail() async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'No user is signed in.',
      );
    }

    await user.reload();

    final refreshed =
        _auth.currentUser;

    if (refreshed != null &&
        !refreshed.emailVerified) {
      await refreshed
          .sendEmailVerification();
    }
  }

  // ==================================================
  // PROFILE
  // ==================================================

  Future<Map<String, dynamic>?>
  getProfile() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    final snapshot =
    await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    return snapshot.data();
  }

  // ==================================================
  // SIGN OUT
  // ==================================================

  Future<void> signOut() {
    return _auth.signOut();
  }
}
import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Вход через Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      // Конвертация User в AppUser
      return AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Google User',
        photoUrl: firebaseUser.photoURL,
      );
    } catch (e, stackTrace) {
      dev.log(
        'Ошибка при входе через Google: $e',
        name: 'AuthService',
        stackTrace: stackTrace,
        error: e,
      );
      return null;
    }
  }


  /// Выход из Firebase и Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      dev.log(
        'Ошибка при выходе: $e',
        name: 'AuthService',
        error: e,
      );
    }
  }

  /// Текущий пользователь Firebase
  User? get currentUser => _auth.currentUser;

  /// Проверка, авторизован ли пользователь
  bool get isSignedIn => currentUser != null;
}
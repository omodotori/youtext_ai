import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Вход через Google
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Запуск выбора Google аккаунта
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // пользователь отменил вход

      // 2. Получаем токены
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Создаём Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Входим через Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
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
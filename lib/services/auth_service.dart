import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import 'profile_service.dart';
// 192.168.43.166
class AuthService {
  static const String baseUrl = 'http://localhost:8000'; // или IP компа

  Future<String?> register(String displayName, String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': displayName,
          'email': email,
          'password': password,
          'isAdmin': false
        }),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Ошибка регистрации (${response.statusCode})';
      }
    } catch (e) {
      return 'Ошибка соединения: $e';
    }
  }


  Future<String?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);

        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Ошибка входа (${response.statusCode})';
      }
    } catch (e) {
      return 'Ошибка соединения: $e';
    }
  }

  Future<String?> logout() async {
    final url = Uri.parse('$baseUrl/api/auth/logout');
    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        print('Нет accessToken — пользователь не авторизован');
        return '';
      }
  
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
  
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Ошибка выхода (${response.statusCode})';
      }
    } catch (e) {
      return 'Ошибка соединения: $e';
    }
  }


  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<AppUser?> signIn(String email, String password) async {
    final error = await login(email, password);
    if (error != null) return null;

    final profile = await ProfileService().getFullProfile();
    // print('DEBUG: user.isAdmin = ${profile.isAdmin}');

    return profile;
  }

// Future<AppUser?> signUp(String displayName, String email, String password) async {
//   final error = await register(displayName, email, password);
//   if (error != null) return null;

//   final profile = await ProfileService().getProfile();
//   return profile;
// }

Future<AppUser?> signUp(String displayName, String email, String password) async {
  final error = await register(displayName, email, password);
  if (error != null) return null;

  // теперь логинимся, чтобы получить токены
  final loginError = await login(email, password);
  if (loginError != null) return null;

  final profile = await ProfileService().getFullProfile();
  return profile;
}

}
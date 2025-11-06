import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import 'auth_service.dart';
import 'package:http_parser/http_parser.dart';


class ProfileService {
  static const String baseUrl = 'http://172.25.240.1:8000';

  Future<AppUser?> getProfile() async {
    try {
      // достаём токен, чтобы авторизоваться
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        print('Нет токена, пользователь не авторизован');
        return null;
      }

      // запрос на получение профиля
      final url = Uri.parse('$baseUrl/api/profile/get');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return AppUser(
          id: data['id'].toString(),
          email: data['email'] ?? '',
          displayName: data['nickname'] ?? '',
        );
      } else {
        print('Ошибка профиля: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при получении профиля: $e');
      return null;
    }
  }

  Future<Uint8List?> getProfilePhoto(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null) return null;

      final url = Uri.parse('$baseUrl/api/profile/get/photo');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 500) {
        print('У пользователя нет аватарки');
        return null;
      } else {
        print('Ошибка получения аватарки: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при запросе фото: $e');
      return null;
    }
  }

    Future<AppUser?> updataUser(String email, String displayName) async {
    final url = Uri.parse('$baseUrl/api/profile/update/user');
    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        print('Нет accessToken — пользователь не авторизован');
        return null;
      }

      final response = await http.post(
        url,
        
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'nickname': displayName,
        }),
      );

      if (response.statusCode == 200) {
        return getFullProfile();
      } else {
        // final data = jsonDecode(response.body);
        return null;
      }
    } catch (e) {
        return null;
      }
    }

    Future<bool> uploadAvatar(File imageFile) async {
      if (imageFile.path.isEmpty) return false;

      try {
        final token = await AuthService().getAccessToken();
        if (token == null) {
          print('Нет accessToken — пользователь не авторизован');
          return false;
        }

        final uri = Uri.parse('$baseUrl/api/profile/update/avatar'); 
        final request = http.MultipartRequest('PUT', uri);
        request.headers['Authorization'] = 'Bearer $token';

        final ext = imageFile.path.split('.').last.toLowerCase();

        if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
          print('Недопустимый формат файла: $ext');
          return false;
        }

        final contentType = ext == 'png'
            ? 'image/png'
            : ext == 'webp'
                ? 'image/webp'
                : 'image/jpeg';

        print('Uploading file: $ext, mime: $contentType');

        final multipartFile = await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType.parse(contentType),
        );

        request.files.add(multipartFile);

        final response = await request.send();

        if (response.statusCode == 200) {
          print('Аватар успешно обновлён');
          return true;
        } else {
          final body = await response.stream.bytesToString();
          print('Ошибка при обновлении аватара: $body');
          return false;
        }
      } catch (e) {
        print('Ошибка при отправке аватара: $e');
        return false;
      }
    }



  

  Future<AppUser?> getFullProfile() async {
    final user = await getProfile();
    if (user == null) return null;

    final photoBytes = await getProfilePhoto(user.id);
    return user.copyWith(photoBytes: photoBytes);
  }

}

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import 'auth_service.dart';
import 'package:http_parser/http_parser.dart';

class ProfileService {
  static const String baseUrl = 'http://localhost:8000';

  Future<AppUser?> getProfile() async {
    try {
      // достаём токен, чтобы авторизоваться
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        dev.log(
          'Нет токена, пользователь не авторизован',
          name: 'ProfileService',
        );
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

        // безопасно обрабатываем поле is_admin, которое может быть bool, int или строкой
        final rawIsAdmin = data['is_admin'];
        final bool isAdmin =
            rawIsAdmin == true ||
            rawIsAdmin == 1 ||
            rawIsAdmin?.toString() == '1';

        return AppUser(
          id: data['id'].toString(),
          email: data['email'] ?? '',
          displayName: data['nickname'] ?? '',
          isAdmin: isAdmin,
        );
      } else {
        dev.log(
          'Ошибка профиля: ${response.statusCode}',
          name: 'ProfileService',
        );
        return null;
      }
    } catch (e, st) {
      dev.log(
        'Ошибка при получении профиля: $e',
        name: 'ProfileService',
        error: e,
        stackTrace: st,
      );
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
        dev.log('У пользователя нет аватарки', name: 'ProfileService');
        return null;
      } else {
        dev.log(
          'Ошибка получения аватарки: ${response.statusCode}',
          name: 'ProfileService',
        );
        return null;
      }
    } catch (e, st) {
      dev.log(
        'Ошибка при запросе фото: $e',
        name: 'ProfileService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<AppUser?> updataUser(String email, String displayName) async {
    final url = Uri.parse('$baseUrl/api/profile/update/user');
    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        dev.log(
          'Нет accessToken — пользователь не авторизован',
          name: 'ProfileService',
        );
        return null;
      }

      final response = await http.post(
        url,

        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'nickname': displayName}),
      );

      if (response.statusCode == 200) {
        return getFullProfile();
      } else {
        // final data = jsonDecode(response.body);
        dev.log(
          'Ошибка обновления профиля: ${response.statusCode}',
          name: 'ProfileService',
        );
        return null;
      }
    } catch (e, st) {
      dev.log(
        'Ошибка при отправке запроса обновления профиля: $e',
        name: 'ProfileService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<bool> uploadAvatar(File imageFile) async {
    if (imageFile.path.isEmpty) return false;

    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        dev.log(
          'Нет accessToken — пользователь не авторизован',
          name: 'ProfileService',
        );
        return false;
      }

      final uri = Uri.parse('$baseUrl/api/profile/update/avatar');
      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      final ext = imageFile.path.split('.').last.toLowerCase();

      if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        dev.log('Недопустимый формат файла: $ext', name: 'ProfileService');
        return false;
      }

      final contentType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
          ? 'image/webp'
          : 'image/jpeg';

      dev.log(
        'Uploading file: $ext, mime: $contentType',
        name: 'ProfileService',
      );

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType.parse(contentType),
      );

      request.files.add(multipartFile);

      final response = await request.send();

      if (response.statusCode == 200) {
        dev.log('Аватар успешно обновлён', name: 'ProfileService');
        return true;
      } else {
        final body = await response.stream.bytesToString();
        dev.log('Ошибка при обновлении аватара: $body', name: 'ProfileService');
        return false;
      }
    } catch (e, st) {
      dev.log(
        'Ошибка при отправке аватара: $e',
        name: 'ProfileService',
        error: e,
        stackTrace: st,
      );
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

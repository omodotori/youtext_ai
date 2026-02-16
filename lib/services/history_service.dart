import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamlit/models/app_user.dart';
import '../models/transcription_record.dart';
import 'auth_service.dart';


class HistoryService {
  static const String baseUrl = 'http://localhost:8000';

  Future<int> getHistoryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null) throw Exception('Нет токена');

      final url = Uri.parse('$baseUrl/api/history/get/count');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        print('Ошибка при получении истории: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Ошибка getHistoryCount: $e');
      return 0;
    }
  }

  Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null) throw Exception('Нет токена');

      final url = Uri.parse('$baseUrl/api/history/delete');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        print('История успешно очищена');
        return true;
      } else {
        print('Ошибка при очистке истории: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Ошибка clearHistory: $e');
      return false;
    }
  }

  Future<List<TranscriptionRecord>> getHistory() async {
    final url = Uri.parse('$baseUrl/api/history/get');

    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        print('Нет accessToken — пользователь не авторизован');
        return [];
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseHistoryRecord(json)).toList();
      } else {
        print('Ошибка при получении истории: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Ошибка соединения (history): $e');
      return [];
    }
  }

  Future<bool> deleteRecord(String historyId) async {
    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        print('❌ Нет accessToken — пользователь не авторизован');
        return false;
      }
      // /api/history/delete/{history_id}
      final url = Uri.parse('$baseUrl/api/history/delete/$historyId');
      print('🗑️ Отправляю DELETE-запрос: $url');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ История $historyId успешно удалена');
        return true;
      } else if (response.statusCode == 404) {
        print('⚠️ История с id=$historyId не найдена');
        return false;
      } else {
        print('❌ Ошибка при удалении: ${response.statusCode}');
        print('Ответ: ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 Ошибка deleteHistoryById: $e');
      return false;
    }
  }


  TranscriptionRecord _parseHistoryRecord(Map<String, dynamic> json) {
    final lines = (json['timecodes'] as List<dynamic>?)
            ?.map((line) => TranscriptLine(
                  timestamp: line['timecode'] ?? '',
                  text: line['descriptions'] ?? '',
                ))
            .toList() ??
        [];

    return TranscriptionRecord(
      id: json['id']?.toString() ?? '',
      videoTitle: json['video_title'] ?? 'Untitled',
      videoUrl: json['video_url'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      transcript: json['transcript'] ?? '',
      lines: lines,
      summary: json['summary'] ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;
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
        dev.log(
          'Ошибка при получении истории: ${response.statusCode}',
          name: 'HistoryService',
        );
        return 0;
      }
    } catch (e) {
      dev.log('Ошибка getHistoryCount: $e', name: 'HistoryService', error: e);
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
        dev.log('История успешно очищена', name: 'HistoryService');
        return true;
      } else {
        dev.log(
          'Ошибка при очистке истории: ${response.statusCode}',
          name: 'HistoryService',
        );
        return false;
      }
    } catch (e) {
      dev.log('Ошибка clearHistory: $e', name: 'HistoryService', error: e);
      return false;
    }
  }

  Future<List<TranscriptionRecord>> getHistory() async {
    final url = Uri.parse('$baseUrl/api/history/get');

    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        dev.log(
          'Нет accessToken — пользователь не авторизован',
          name: 'HistoryService',
        );
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
        dev.log(
          'Ошибка при получении истории: ${response.statusCode}',
          name: 'HistoryService',
        );
        return [];
      }
    } catch (e) {
      dev.log(
        'Ошибка соединения (history): $e',
        name: 'HistoryService',
        error: e,
      );
      return [];
    }
  }

  TranscriptionRecord _parseHistoryRecord(Map<String, dynamic> json) {
    final lines =
        (json['timecodes'] as List<dynamic>?)
            ?.map(
              (line) => TranscriptLine(
                timestamp: line['timecode'] ?? '',
                text: line['descriptions'] ?? '',
              ),
            )
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
      highlights:
          (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

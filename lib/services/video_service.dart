import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
// import 'package:shared_preferences/shared_preferences.dart';
import '../models/transcription_record.dart';
import 'auth_service.dart';

class VideoService {
  static const String baseUrl = 'http://localhost:8000'; // поменяешь если нужно

  /// Получить Summary для **гостя**
  Future<TranscriptionRecord?> getVideoSummaryAnon(String videoUrl) async {
    final url = Uri.parse('$baseUrl/api/ai/video/anon');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': videoUrl, 'type': 'summary'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseSummary(data);
      } else {
        dev.log(
          'Ошибка гостевого запроса: ${response.statusCode}',
          name: 'VideoService',
        );
        return null;
      }
    } catch (e) {
      dev.log('Ошибка соединения (anon): $e', name: 'VideoService', error: e);
      return null;
    }
  }

  /// Получить Summary для **зарегистрированного пользователя**
  Future<TranscriptionRecord?> getVideoSummary(String videoUrl) async {
    final url = Uri.parse('$baseUrl/api/ai/video');

    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        dev.log(
          'Нет accessToken — пользователь не авторизован',
          name: 'VideoService',
        );
        return null;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'url': videoUrl, 'type': 'summary'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseSummary(data);
      } else {
        dev.log(
          'Ошибка авторизованного запроса: ${response.statusCode}',
          name: 'VideoService',
        );
        return null;
      }
    } catch (e) {
      dev.log('Ошибка соединения (auth): $e', name: 'VideoService', error: e);
      return null;
    }
  }

  /// Парсер JSON → TranscriptionRecord
  TranscriptionRecord _parseSummary(Map<String, dynamic> json) {
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
      id: json['user_id']?.toString() ?? '',
      videoTitle: json['video_title'] ?? '',
      videoUrl: json['link'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      transcript: json['transcript'] ?? '',
      lines: lines,
      summary: json['text'] ?? '',
      highlights:
          (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/transcription_record.dart';
import 'pages/history_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/result_screen.dart';

void main() => runApp(const YouTextApp());

class YouTextApp extends StatefulWidget {
  const YouTextApp({super.key});

  @override
  State<YouTextApp> createState() => _YouTextAppState();
}

class _YouTextAppState extends State<YouTextApp> {
  final TextEditingController _urlController = TextEditingController();
  final List<TranscriptionRecord> _history = [];
  TranscriptionRecord? _lastResult;
  int _tabIndex = 0;
  bool _isProcessing = false;
  double _progress = 0.0;
  Timer? _progressTimer;

  @override
  void dispose() {
    _progressTimer?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.dark,
    );
    final colorScheme = baseScheme.copyWith(
      onSurface: const Color(0xFFFFFFFF),
      onSurfaceVariant: const Color(0xFFD4DCFF),
      surface: const Color(0xFF10192C),
      surfaceContainerHighest: const Color(0xFF1A2439),
      outlineVariant: const Color(0xFF27324A),
    );
    final baseTextTheme = ThemeData(brightness: Brightness.dark).textTheme;
    final textTheme = baseTextTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF080C14),
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF080C14),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardColor: colorScheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1F2937)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1F2937)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color.fromRGBO(37, 99, 235, 0.8)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: const TextStyle(color: Color(0xFFA7B4D7)),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouText',
      theme: theme,
      home: Scaffold(
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildBody(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF080C14),
          currentIndex: _tabIndex,
          onTap: _setTab,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_tabIndex) {
      case 0:
        return HomePage(
          tabIndex: _tabIndex,
          onTabSelected: _setTab,
          urlController: _urlController,
          isProcessing: _isProcessing,
          progress: _progress,
          lastResult: _lastResult,
          history: _history,
          onStartTranscription: _startTranscription,
          onOpenResult: _openResult,
          onCopyRecord: _copyRecord,
        );
      case 1:
        return HistoryPage(
          tabIndex: _tabIndex,
          onTabSelected: _setTab,
          history: _history,
          onOpenRecord: _openResult,
          onDeleteRecord: _deleteRecord,
        );
      case 2:
        return ProfilePage(
          tabIndex: _tabIndex,
          onTabSelected: _setTab,
          historyCount: _history.length,
          onClearHistory: _clearHistory,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _setTab(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
  }

  void _deleteRecord(TranscriptionRecord record) {
    setState(() => _history.removeWhere((item) => item.id == record.id));
  }

  void _copyRecord(TranscriptionRecord record) {
    Clipboard.setData(ClipboardData(text: record.transcript));
    _showSnack('Transcript copied to clipboard.');
  }

  void _clearHistory() {
    if (_history.isEmpty) return;
    setState(() {
      _history.clear();
    });
  }

  Future<void> _startTranscription() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnack('Paste a YouTube link first.');
      return;
    }
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _progress = 0;
    });

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      setState(() {
        _progress = (_progress + 0.05).clamp(0.0, 0.85);
      });
    });

    try {
      final record = await _simulateTranscription(url);
      _progressTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _progress = 1.0;
        _lastResult = record;
      });
      _addToHistory(record);
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ResultScreen(record: record)));
    } catch (error) {
      _progressTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _progress = 0;
      });
      _showSnack('Failed to transcribe: $error');
    }
  }

  Future<TranscriptionRecord> _simulateTranscription(String url) async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    final title = _extractTitleFromUrl(url);
    final random = Random();
    final template = <String>[
      'Whisper is an open speech recognition model by OpenAI.',
      'Pipeline: yt-dlp -> ffmpeg -> Whisper.',
      'Everything runs locally without paid APIs.',
      'Short clips work best for quick demos.',
      'You can edit, copy and file the text.',
    ];

    final lines = <TranscriptLine>[];
    var seconds = 0;
    for (final sentence in template) {
      final timestamp = _formatTimestamp(Duration(seconds: seconds));
      lines.add(TranscriptLine(timestamp: timestamp, text: sentence));
      seconds += 8 + random.nextInt(6);
    }

    final transcript = lines
        .map((line) => '[${line.timestamp}] ${line.text}')
        .join('\n');

    final summary =
        'The video "$title" walks through an offline pipeline: download audio, convert to WAV and run Whisper without any external API.';

    return TranscriptionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoTitle: title,
      videoUrl: url,
      createdAt: DateTime.now(),
      transcript: transcript,
      lines: lines,
      summary: summary,
    );
  }

  void _addToHistory(TranscriptionRecord record) {
    setState(() {
      _history.removeWhere((item) => item.id == record.id);
      _history.insert(0, record);
    });
  }

  Future<void> _openResult(TranscriptionRecord record) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ResultScreen(record: record)));
    if (!mounted) return;
    setState(() {
      _lastResult = record;
      _tabIndex = 0;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _extractTitleFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) {
      return 'YouTube video';
    }
    return uri.pathSegments.last;
  }

  String _formatTimestamp(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
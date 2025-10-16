import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          onTap: (index) => setState(() => _tabIndex = index),
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
        return _buildHome();
      case 1:
        return _buildHistory();
      case 2:
        return _buildProfile();
      default:
        return const SizedBox.shrink();
    }
  }

  List<Widget> _buildPageHeader(ThemeData theme, String title) {
    return [
      Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 12),
      _buildTabSwitcher(theme),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildTabSwitcher(ThemeData theme) {
    final labels = ['Home', 'History', 'Profile'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (index) {
        final isActive = _tabIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (_tabIndex != index) {
                setState(() => _tabIndex = index);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[index],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _copyRecord(TranscriptionRecord record) {
    Clipboard.setData(ClipboardData(text: record.transcript));
    _showSnack('Transcript copied to clipboard.');
  }

  Widget _buildHome() {
    final theme = Theme.of(context);
    final recent = _history.take(3).toList();

    return ListView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        ..._buildPageHeader(theme, 'Home'),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Enter YouTube video URL',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF7C8AA6),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _isProcessing ? null : _startTranscription,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _isProcessing
                        ? Row(
                            key: const ValueKey('processing'),
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Processing...'),
                            ],
                          )
                        : const Text('Transcribe'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _isProcessing
              ? _buildProgressCard(theme)
              : const SizedBox.shrink(key: ValueKey('progress-empty')),
        ),
        if (_lastResult != null) ...[
          const SizedBox(height: 28),
          Text(
            'Latest transcription',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ResultCard(
            record: _lastResult!,
            onOpen: () => _openResult(_lastResult!),
            onCopy: () => _copyRecord(_lastResult!),
          ),
        ],
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            'My transcriptions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (final record in recent) ...[
            _HistoryTile(record: record, onTap: () => _openResult(record)),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  Widget _buildProgressCard(ThemeData theme) {
    final progressValue = _progress <= 0 ? null : _progress.clamp(0.0, 1.0);
    final activeStep = progressValue == null
        ? 0
        : progressValue < 0.45
        ? 0
        : progressValue < 0.9
        ? 1
        : 2;
    final stepIcons = <IconData>[
      Icons.link_rounded,
      Icons.graphic_eq_rounded,
      Icons.article_rounded,
    ];
    final stepLabels = <String>[
      'Fetching audio',
      'Transcribing with Whisper',
      'Summarising highlights',
    ];

    final headline = progressValue == 1.0
        ? 'All done!'
        : 'Processing your video';
    final subhead = progressValue == 1.0
        ? 'Transcript saved to your history and ready to review.'
        : 'Feel free to explore other transcripts while we work in the background.';
    final leadingIcon = progressValue == 1.0
        ? Icons.check_circle_rounded
        : Icons.hourglass_top_rounded;

    return Container(
      key: const ValueKey('progress-card'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(31),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  leadingIcon,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subhead,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: theme.colorScheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (var i = 0; i < stepIcons.length; i++) ...[
                Expanded(
                  child: _buildProgressStep(
                    theme: theme,
                    icon: stepIcons[i],
                    label: stepLabels[i],
                    isActive:
                        !_isStepCompleted(progressValue, i) && activeStep == i,
                    isCompleted: _isStepCompleted(progressValue, i),
                  ),
                ),
                if (i != stepIcons.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  bool _isStepCompleted(double? progressValue, int index) {
    if (progressValue == null) return false;
    switch (index) {
      case 0:
        return progressValue >= 0.45;
      case 1:
        return progressValue >= 0.9;
      case 2:
        return progressValue >= 1.0;
      default:
        return false;
    }
  }

  Widget _buildProgressStep({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    final highlightColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface;
    final iconToShow = isCompleted ? Icons.check_rounded : icon;
    final iconColor = isCompleted || isActive ? highlightColor : inactiveColor;
    final containerColor = isCompleted
        ? highlightColor.withAlpha(46)
        : isActive
        ? highlightColor.withAlpha(31)
        : theme.colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(iconToShow, color: iconColor, size: 20),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isCompleted || isActive
                ? FontWeight.w600
                : FontWeight.w500,
            color: isCompleted || isActive
                ? theme.colorScheme.onSurface
                : inactiveColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    final theme = Theme.of(context);

    if (_history.isEmpty) {
      return ListView(
        key: const ValueKey('history-empty'),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        children: [
          ..._buildPageHeader(theme, 'History'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: theme.colorScheme.primary.withAlpha(38),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.hourglass_empty_rounded,
                    color: theme.colorScheme.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'No transcriptions yet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Drop in a YouTube link from the Home tab to start building your library.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => setState(() => _tabIndex = 0),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Go to Home'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      key: const ValueKey('history'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        ..._buildPageHeader(theme, 'History'),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: theme.colorScheme.primary.withAlpha(38),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.library_books_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your transcript library',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_history.length} saved ${_history.length == 1 ? 'clip' : 'clips'} - swipe left to delete',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (final record in _history) ...[
          Dismissible(
            key: ValueKey(record.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => setState(
              () => _history.removeWhere((item) => item.id == record.id),
            ),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            child: _HistoryTile(
              record: record,
              onTap: () => _openResult(record),
            ),
          ),
          if (record != _history.last) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildProfile() {
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('profile'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        ..._buildPageHeader(theme, 'Profile'),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3730A3), Color(0xFF1E1B4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'YT',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'YouText demo profile',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Everything stays on-device. Organise and copy transcripts whenever you need them.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved transcripts',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Watch history stays private and local to this device.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _history.length.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'YouText runs Whisper locally so you can transcribe without external services.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _history.isEmpty
                      ? null
                      : () => setState(() => _history.clear()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withAlpha(128),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear history'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final now = DateTime.now();
  final monthLabel = months[date.month - 1];
  final yearSuffix = date.year == now.year ? '' : ', ${date.year}';
  return '$monthLabel ${date.day}$yearSuffix';
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.record,
    required this.onOpen,
    required this.onCopy,
  });

  final TranscriptionRecord record;
  final VoidCallback onOpen;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewLines = record.lines.take(3).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'WH',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.videoTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          previewLines.isNotEmpty
                              ? previewLines.first.timestamp
                              : '00:00',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
              if (previewLines.isNotEmpty) ...[
                const SizedBox(height: 18),
                for (final line in previewLines) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(
                          line.timestamp,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          line.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (line != previewLines.last) const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: onCopy,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Copy Text'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record, required this.onTap});

  final TranscriptionRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3730A3), Color(0xFF1E1B4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.videoTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(record.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TranscriptionRecord {
  const TranscriptionRecord({
    required this.id,
    required this.videoTitle,
    required this.videoUrl,
    required this.createdAt,
    required this.transcript,
    required this.lines,
    required this.summary,
  });

  final String id;
  final String videoTitle;
  final String videoUrl;
  final DateTime createdAt;
  final String transcript;
  final List<TranscriptLine> lines;
  final String summary;
}

class TranscriptLine {
  const TranscriptLine({required this.timestamp, required this.text});

  final String timestamp;
  final String text;
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.record});

  final TranscriptionRecord record;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.record.transcript);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _editController.text));
    _showSnack('Transcript copied to clipboard.');
  }

  void _copyLine(TranscriptLine line) {
    Clipboard.setData(ClipboardData(text: '[${line.timestamp}] ${line.text}'));
    _showSnack('Line copied.');
  }

  void _openEditor() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit transcript',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _editController,
                maxLines: 12,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.record.videoTitle)),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'copy',
            onPressed: _copyAll,
            icon: const Icon(Icons.copy_all_rounded),
            label: const Text('Copy all'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'edit',
            onPressed: _openEditor,
            child: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Text('Source', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(
            widget.record.videoUrl,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text('Summary', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(widget.record.summary, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text('Transcript', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final line in widget.record.lines) ...[
            InkWell(
              onTap: () => _copyLine(line),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        line.timestamp,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        line.text,
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

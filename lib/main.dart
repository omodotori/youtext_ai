import 'dart:async';
import 'dart:math';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'models/app_user.dart';
import 'models/transcription_record.dart';
import 'pages/auth/sign_in_page.dart';
import 'pages/auth/sign_up_page.dart';
import 'pages/history_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/result_screen.dart';




final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const YouTextApp());
}

final ColorScheme _appColorScheme = const ColorScheme.dark(
  primary: Color(0xFF2563EB),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF1D4ED8),
  onPrimaryContainer: Color(0xFFEFF4FF),
  secondary: Color(0xFF3B82F6),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF1E3A8A),
  onSecondaryContainer: Color(0xFFDBEAFE),
  tertiary: Color(0xFF1D4ED8),
  onTertiary: Color(0xFFFFFFFF),
  surface: Color(0xFF18181B),
  onSurface: Color(0xFFFFFFFF),
  surfaceContainerHighest: Color(0xFF1C1C1E),
  onSurfaceVariant: Color(0xFF9CA3AF),
  outline: Color(0xFF2F3138),
  error: Color(0xFFF87171),
  onError: Color(0xFFFFFFFF),
).copyWith(
  surfaceTint: const Color(0xFF2563EB),
  outlineVariant: const Color(0xFF2F3138),
);

const Color _scaffoldBackgroundColor = Color(0xFF0E0E10);

class YouTextApp extends StatefulWidget {
  const YouTextApp({super.key});

  @override
  State<YouTextApp> createState() => _YouTextAppState();
}

class _YouTextAppState extends State<YouTextApp> {
  Locale _locale = const Locale('en');

    void _changeLanguage(Locale locale) {
      setState(() {
        _locale = locale;
      });
    }

  final TextEditingController _urlController = TextEditingController();
  final List<TranscriptionRecord> _history = [];
  TranscriptionRecord? _lastResult;
  int _tabIndex = 0;
  bool _isProcessing = false;
  double _progress = 0.0;
  Timer? _progressTimer;
  bool _isAuthenticating = false;
  AppUser? _currentUser;
  final List<AppUser> _registeredUsers = [];
  bool _includeTranscript = true;
  bool _includeSummary = true;

  @override
  void dispose() {
    _progressTimer?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = _appColorScheme;
    final baseTextTheme = ThemeData(brightness: Brightness.dark).textTheme;
    final textTheme = baseTextTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _scaffoldBackgroundColor,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: _scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardColor: colorScheme.surface,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle:
              textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'YouText',
      theme: theme,
      //смена языка
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      //смена языка
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildBody(),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: theme.colorScheme.surface,
            currentIndex: _tabIndex,
            onTap: _setTab,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurfaceVariant,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: AppLocalizations.of(context).t('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_rounded),
                label: AppLocalizations.of(context).t('history'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_rounded),
                label: AppLocalizations.of(context).t('profile'),
              ),
            ],
          ),
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
          isSignedIn: _currentUser != null,
          generateTranscript: _includeTranscript,
          generateSummary: _includeSummary,
          onToggleGenerateTranscript: _setIncludeTranscript,
          onToggleGenerateSummary: _setIncludeSummary,
          onStartTranscription: _startTranscription,
          onOpenResult: _openResult,
          onCopyRecord: _copyRecord,
        );
      case 1:
        return HistoryPage(
          tabIndex: _tabIndex,
          onTabSelected: _setTab,
          history: _history,
          isSignedIn: _currentUser != null,
          onOpenRecord: _openResult,
          onDeleteRecord: _deleteRecord,
        );
      case 2:
        return Stack(
          children: [
            ProfilePage(
              tabIndex: _tabIndex,
              onTabSelected: _setTab,
              historyCount: _history.length,
              isSignedIn: _currentUser != null,
              isAuthenticating: _isAuthenticating,
              user: _currentUser,
              onEmailSignIn: _openEmailSignIn,
              onEmailSignUp: _openEmailSignUp,
              onGoogleSignIn: _signInWithGoogle,
              onSignOut: _signOut,
              onClearHistory: _clearHistory,
              onLanguageChanged: _changeLanguage,
              
            ),
            // Positioned(
            //   right: 20,
            //   bottom: 20,
            //   child: FloatingActionButton(
            //     onPressed: () {
            //       if (_locale.languageCode == 'en') {
            //         _changeLanguage(const Locale('ru'));
            //         _showSnack('Язык: Русский');
            //       } else {
            //         _changeLanguage(const Locale('en'));
            //         _showSnack('Language: English');
            //       }
            //     },
            //     child: const Icon(Icons.language),
            //   ),
            // ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _setTab(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
  }

  void _setIncludeTranscript(bool value) {
    if (_includeTranscript == value) return;
    if (!value && !_includeSummary) {
      _showSnack('Select at least one output format.');
      return;
    }
    setState(() => _includeTranscript = value);
  }

  void _setIncludeSummary(bool value) {
    if (_includeSummary == value) return;
    if (!value && !_includeTranscript) {
      _showSnack('Select at least one output format.');
      return;
    }
    setState(() => _includeSummary = value);
  }

  void _deleteRecord(TranscriptionRecord record) {
    setState(() => _history.removeWhere((item) => item.id == record.id));
  }

  void _copyRecord(TranscriptionRecord record) {
    if (record.transcript.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: record.transcript));
      _showSnack('Transcript copied to clipboard.');
      return;
    }
    if (record.summary.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: record.summary));
      _showSnack('Summary copied to clipboard.');
      return;
    }
    _showSnack('Nothing to copy for this result.');
  }

  void _clearHistory() {
    if (_history.isEmpty) return;
    setState(() {
      _history.clear();
    });
    _showSnack('History cleared.');
  }

  Future<void> _signInWithGoogle() async {
    if (_isAuthenticating || _currentUser != null) return;
    setState(() => _isAuthenticating = true);

    try {
      final auth = FirebaseAuth.instance;

      if (kIsWeb) {
        // --- ВЕБ ---
        final googleProvider = GoogleAuthProvider();
        final userCredential = await auth.signInWithPopup(googleProvider);
        final firebaseUser = userCredential.user;

        if (firebaseUser != null && mounted) {
          final appUser = AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'Google User',
            photoUrl: firebaseUser.photoURL,
          );
          setState(() {
            _currentUser = appUser;
            if (!_registeredUsers.any((u) => u.id == appUser.id)) {
              _registeredUsers.add(appUser);
            }
          });
          _showSnack('Signed in with Google (Web).');
        }
      } else {
        // --- ANDROID / IOS ---
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          if (mounted) {
            setState(() => _isAuthenticating = false);
            _showSnack('Google Sign-In cancelled.');
          }
          return;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await auth.signInWithCredential(credential);
        final firebaseUser = userCredential.user;

        if (firebaseUser != null && mounted) {
          final appUser = AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'Google User',
          );
          setState(() {
            _currentUser = appUser;
            if (!_registeredUsers.any((u) => u.id == appUser.id)) {
              _registeredUsers.add(appUser);
            }
          });
          _showSnack('Signed in with Google.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Google Sign-In failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }


  void _signOut() {
    if (_currentUser == null) return;
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    setState(() {
      _currentUser = null;
    });
    _showSnack('Signed out.');
  }

  Future<String?> _handleEmailSignIn(String email, String password) async {
    if (_isAuthenticating || _currentUser != null) return null;
    setState(() => _isAuthenticating = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null && mounted) {
        final appUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? email.trim(),
        );
        setState(() {
          _currentUser = appUser;
          if (!_registeredUsers.any((u) => u.id == appUser.id)) {
            _registeredUsers.add(appUser);
          }
        });
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'user-not-found') {
          return 'No account found for this email.';
        } else if (e.code == 'wrong-password') {
          return 'Incorrect password.';
        } else {
          return 'Sign-in failed: ${e.message}';
        }
      }
    } catch (e) {
      if (mounted) {
        return 'Sign-in failed: $e';
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
    return null;
  }

  Future<String?> _handleEmailSignUp(
    String displayName,
    String email,
    String password,
  ) async {
    if (_isAuthenticating || _currentUser != null) return null;
    setState(() => _isAuthenticating = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null && mounted) {
        await firebaseUser.updateDisplayName(displayName.trim());
        final appUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: displayName.trim(),
        );
        setState(() {
          _currentUser = appUser;
          if (!_registeredUsers.any((u) => u.id == appUser.id)) {
            _registeredUsers.add(appUser);
          }
        });
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'email-already-in-use') {
          return 'This email is already registered.';
        } else if (e.code == 'weak-password') {
          return 'Password is too weak.';
        } else {
          return 'Sign-up failed: ${e.message}';
        }
      }
    } catch (e) {
      if (mounted) {
        return 'Sign-up failed: $e';
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
    return null;
  }

  Future<AppUser?> _handleGoogleSignInFromForm() async {
    final before = _currentUser;
    await _signInWithGoogle();

    if (_currentUser != null && _currentUser != before) {
      return _currentUser;
    }
    return null;
  }
  Future<void> _openEmailSignIn() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SignInPage(
          onSubmit: _handleEmailSignIn,
          onGoogleSignIn: _handleGoogleSignInFromForm,
        ),
      ),
    );
    if (result == true && mounted) {
      _showSnack('Welcome back!');
    }
  }


  Future<void> _openEmailSignUp() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SignUpPage(
          onSubmit: _handleEmailSignUp,
          onGoogleSignIn: _handleGoogleSignInFromForm,
        ),
      ),
    );
    if (result == true && mounted) {
      _showSnack('Account created.');
    }
  }



  Future<void> _startTranscription() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnack('Paste a YouTube link first.');
      return;
    }
    if (!_includeTranscript && !_includeSummary) {
      _showSnack('Choose what to generate first.');
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
      final record = await _simulateTranscription(
        url,
        includeTranscript: _includeTranscript,
        includeSummary: _includeSummary,
      );
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

  Future<TranscriptionRecord> _simulateTranscription(
    String url, {
    required bool includeTranscript,
    required bool includeSummary,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    final title = _extractTitleFromUrl(url);
    final template = <String>[
      'Whisper is an open speech recognition model by OpenAI.',
      'Pipeline: yt-dlp -> ffmpeg -> Whisper.',
      'Everything runs locally without paid APIs.',
      'Short clips work best for quick demos.',
      'You can edit, copy and file the text.',
    ];

    final List<TranscriptLine> lines;
    final String transcript;
    if (includeTranscript) {
      final generatedLines = <TranscriptLine>[];
      final random = Random();
      var seconds = 0;
      for (final sentence in template) {
        final timestamp = _formatTimestamp(Duration(seconds: seconds));
        generatedLines.add(
          TranscriptLine(timestamp: timestamp, text: sentence),
        );
        seconds += 8 + random.nextInt(6);
      }
      lines = generatedLines;
      transcript = generatedLines
          .map((line) => '[${line.timestamp}] ${line.text}')
          .join('\n');
    } else {
      lines = const <TranscriptLine>[];
      transcript = '';
    }

    final String summary;
    final List<String> highlights;
    if (includeSummary) {
      summary =
          'Quick recap for "$title": audio was fetched locally, Whisper processed it offline and produced actionable notes.';
      highlights = const <String>[
        'Audio downloaded with yt-dlp and converted with ffmpeg.',
        'Whisper handled speech-to-text fully on device.',
        'Short videos give faster results in this proof-of-concept.',
      ];
    } else {
      summary = '';
      highlights = const <String>[];
    }

    return TranscriptionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoTitle: title,
      videoUrl: url,
      createdAt: DateTime.now(),
      transcript: transcript,
      lines: lines,
      summary: summary,
      highlights: highlights,
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
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      debugPrint('⚠ Snackbar context is null');
    }
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
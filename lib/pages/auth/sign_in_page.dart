import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../models/app_user.dart';
import 'reset_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
    required this.onSubmit,
    required this.onGoogleSignIn,
    required this.onRequestCode,
    required this.onSubmitReset,
  });

  final Future<String?> Function(String email, String password) onSubmit;
  final Future<AppUser?> Function() onGoogleSignIn;

  final Future<String?> Function(String email) onRequestCode;
  final Future<String?> Function(String email, String code, String newPassword) onSubmitReset;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorText;
  Locale _locale = const Locale('en');

  void _openResetPasswordPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ForgotPasswordPage(
          onRequestCode: widget.onRequestCode,
          onSubmitReset: widget.onSubmitReset,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _changeLanguage(Locale locale) {
    setState(() => _locale = locale);
  }

  String t(String en, String ru) {
    return _locale.languageCode == 'ru' ? ru : en;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final result = await widget.onSubmit(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _errorText = result);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final user = await widget.onGoogleSignIn();

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (user != null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _errorText = t('Google sign-in failed', 'Ошибка входа через Google'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Localizations(
      locale: _locale,
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('Sign in', 'Вход')),
          actions: [
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language),
              onSelected: _changeLanguage,
              itemBuilder: (context) => [
                const PopupMenuItem(value: Locale('en'), child: Text('🇺🇸 English')),
                const PopupMenuItem(value: Locale('ru'), child: Text('🇷🇺 Русский')),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            Text(
              t('Access your transcripts', 'Войдите в свой аккаунт'),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              t(
                'Use your account to save history across sessions.',
                'Используйте аккаунт, чтобы сохранять историю сессий.',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (_errorText != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorText!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: t('Email', 'Почта'),
                      prefixIcon: const Icon(Icons.mail_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t('Email is required.', 'Введите почту.');
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return t('Enter a valid email.', 'Введите корректный адрес.');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: t('Password', 'Пароль'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? t('Password is required.', 'Введите пароль.')
                            : null,
                  ),
                  
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isSubmitting ? null : _openResetPasswordPage, // <-- ЗАМЕНИТЬ НА ЭТО
                        child: Text(t('Forgot password?', 'Забыли пароль?')),
                      ),
                  ),
                  
                ],
              ),
            ),
            const SizedBox(height: 8), // Немного уменьшил отступ, т.к. добавилась кнопка
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t('Sign in', 'Войти')),
              ),
            ),
            const SizedBox(height: 16),
           
          ],
        ),
      ),
    );
  }
}
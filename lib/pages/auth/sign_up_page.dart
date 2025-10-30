import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../models/app_user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
    required this.onSubmit,
    required this.onGoogleSignIn,
  });

  final Future<String?> Function(String displayName, String email, String password) onSubmit;
  final Future<AppUser?> Function() onGoogleSignIn;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorText;
  Locale _locale = const Locale('en');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
      _nameController.text.trim(),
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
          title: Text(t('Create account', 'Создать аккаунт')),
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
              t('Set up your YouText account', 'Создайте свой аккаунт YouText'),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              t(
                'Register to keep history, summaries and highlights backed up.',
                'Регистрируйтесь, чтобы сохранять историю, конспекты и заметки.',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: t('Display name', 'Имя пользователя'),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t('Display name is required.', 'Введите имя пользователя.');
                      }
                      if (value.trim().length < 3) {
                        return t('Display name must be at least 3 characters.', 'Имя должно быть не короче 3 символов.');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t('Password is required.', 'Введите пароль.');
                      }
                      if (value.length < 6) {
                        return t('Password must be at least 6 characters.', 'Пароль должен быть не короче 6 символов.');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: t('Confirm password', 'Подтвердите пароль'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t('Confirm your password.', 'Введите подтверждение пароля.');
                      }
                      if (value != _passwordController.text) {
                        return t('Passwords do not match.', 'Пароли не совпадают.');
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(t('Create account', 'Создать аккаунт')),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _signInWithGoogle,
                icon: const Icon(Icons.login_rounded),
                label: Text(t('Continue with Google', 'Войти через Google')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

enum ResetStep { emailInput, codeAndNewPassword }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    required this.onRequestCode,
    required this.onSubmitReset,
  });

  final Future<String?> Function(String email) onRequestCode;
  
  final Future<String?> Function(String email, String code, String newPassword) onSubmitReset;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  ResetStep _currentStep = ResetStep.emailInput;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorText;
  String? _successText; // Для сообщения "Код отправлен"
  Locale _locale = const Locale('en');

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _changeLanguage(Locale locale) {
    setState(() => _locale = locale);
  }

  String t(String en, String ru) {
    return _locale.languageCode == 'ru' ? ru : en;
  }

  Future<void> _submitEmail() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
      _successText = null;
    });

    final result = await widget.onRequestCode(_emailController.text.trim());

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result == null) {
      setState(() {
        _currentStep = ResetStep.codeAndNewPassword;
        _successText = t('Code sent to your email.', 'Код отправлен на вашу почту.');
      });
    } else {
      setState(() => _errorText = result);
    }
  }

  Future<void> _submitReset() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
      _successText = null;
    });

    final result = await widget.onSubmitReset(
      _emailController.text.trim(),
      _codeController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('Password changed successfully!', 'Пароль успешно изменен!'))),
      );
      Navigator.of(context).pop(); // Возвращаемся на экран входа
    } else {
      setState(() => _errorText = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStep1 = _currentStep == ResetStep.emailInput;

    return Localizations(
      locale: _locale,
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('Recovery', 'Восстановление')),
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
              isStep1 
                  ? t('Forgot password?', 'Забыли пароль?') 
                  : t('Reset password', 'Сброс пароля'),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              isStep1
                  ? t('Enter your email to receive a reset code.', 'Введите почту для получения кода.')
                  : t('Enter the code sent to ${_emailController.text} and your new password.', 'Введите код, отправленный на ${_emailController.text}, и новый пароль.'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            if (_errorText != null) ...[
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
            ],

            if (_successText != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successText!,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green[800]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (isStep1)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: t('Email', 'Почта'),
                        prefixIcon: const Icon(Icons.mail_outline),
                        border: const OutlineInputBorder(),
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

                  if (!isStep1) ...[
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: t('Code from email', 'Код из письма'),
                        prefixIcon: const Icon(Icons.pin_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? t('Code is required.', 'Введите код.')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: t('New Password', 'Новый пароль'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t('Password is required.', 'Введите пароль.');
                        }
                        if (value.length < 8) {
                          return t('Password must be at least 8 chars.', 'Пароль должен быть не короче 8 символов.');
                        }
                        if (value.length > 32) {
                          return t('Password must not exceed 32 chars.', 'Пароль не должен превышать 32 символа.');
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting 
                    ? null 
                    : (isStep1 ? _submitEmail : _submitReset),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isStep1 
                            ? t('Send Code', 'Отправить код') 
                            : t('Reset Password', 'Сменить пароль')
                      ),
              ),
            ),

            if (!isStep1) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _currentStep = ResetStep.emailInput;
                            _errorText = null;
                            _successText = null;
                          });
                        },
                  child: Text(t('Back to email', 'Назад к вводу почты')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
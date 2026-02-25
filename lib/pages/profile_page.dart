import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/history_service.dart';
import '../l10n.dart';
import 'edit_profile_page.dart';
import '../pages/auth/sign_in_page.dart';
import '../pages/auth/sign_up_page.dart';
import 'admin_panel_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.tabIndex,
    required this.onTabSelected,
    required this.historyCount,
    required this.isAuthenticating,
    required this.user,
    required this.onEmailSignIn,
    required this.onEmailSignUp,
    required this.onGoogleSignIn,
    required this.onSignOut,
    required this.onClearHistory,
    required this.onLanguageChanged,
    required this.onUserUpdated,
  });

  final int tabIndex;
  final ValueChanged<int> onTabSelected;
  final int historyCount;
  final bool isAuthenticating;
  final AppUser? user;
  final Future<void> Function() onEmailSignIn;
  final Future<void> Function() onEmailSignUp;
  final Future<void> Function() onGoogleSignIn;
  final VoidCallback onSignOut;
  final VoidCallback onClearHistory;
  final void Function(Locale) onLanguageChanged;
  final void Function(AppUser? updatedUser) onUserUpdated;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late HistoryService _historyService;
  late AuthService _authService;
  late ProfileService _profileService;
  AppUser? _user;

  int _historyCount = 0;
  bool _isLoadingHistory = false;


  bool get isSignedIn => _user != null;

  @override
  void initState() {
    super.initState();
    _historyService = HistoryService();
    _authService = AuthService();
    _profileService = ProfileService();
    _user = widget.user;

    if (_user != null) {
      _fetchHistoryCount();
    }

  }

  Future<void> _fetchHistoryCount() async {
    setState(() => _isLoadingHistory = true);
    try {
      final count = await _historyService.getHistoryCount();
      setState(() => _historyCount = count);
    } catch (e) {
      print('Ошибка загрузки количества истории: $e');
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _clearHistory() async {
    final success = await _historyService.clearHistory();
    if (success) {
      setState(() => _historyCount = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('История успешно очищена')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось очистить историю')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    final displayName = _user?.displayName.trim().isNotEmpty == true
        ? _user!.displayName
        : loc.t('youtext_user');
    final email = _user?.email;
    final initials = (displayName.isNotEmpty ? displayName[0] : 'Y').toUpperCase();

    return ListView(
      key: const ValueKey('profile'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
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
                  gradient: _user?.photoBytes == null
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: _user?.photoBytes != null
                    ? CircleAvatar(
                        radius: 44,
                        backgroundImage: MemoryImage(_user!.photoBytes!),
                      )
                    : Text(
                        initials,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: 18),
              Text(
                isSignedIn ? displayName : loc.t('guest_profile'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (email != null) ...[
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              if (isSignedIn)
                _signedInButtons(context, loc)
              else
                _signInOptions(context, loc),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _historyAndAbout(theme, loc),
        const SizedBox(height: 24),
        _languageSelector(theme, loc),
      ],
    );
  }

  Widget _signedInButtons(BuildContext context, AppLocalizations loc) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                  user: _user,
                  onUserUpdated: (updatedUser) {
                    widget.onUserUpdated(updatedUser);
                  },
                ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: Text(loc.t('edit_profile')),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await _authService.logout();
              if (result == null) {
                widget.onSignOut();
                widget.onUserUpdated(null);
                setState(() => _user = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Вы успешно вышли')),
                );
              } else {
                // произошла ошибка
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка при выходе: $result')),
                );
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: Text(loc.t('sign_out')),
          ),
        ),
      ],
    );
  }

  Widget _signInOptions(BuildContext context, AppLocalizations loc) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignInPage(
                    onSubmit: (email, password) async {
                      final user = await _authService.signIn(email, password);
                      if (user != null) {
                        widget.onUserUpdated(user);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Вход выполнен успешно')),
                        );
                        
                        setState(() {
                          _user = user;
                        });

                        if (_user?.isAdmin == true) {
                          Future.microtask(() {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminPanelPage()),
                            );
                          });
                          return null;
                        }
                        return null;
                      } else {
                        return 'Ошибка входа';
                      }
                    },
                    onGoogleSignIn: () async {
                      await widget.onGoogleSignIn();
                      return null;
                    },
                    
                    onRequestCode: (email) async {
                      return await _authService.forgotPassword(email);
                    },

                    onSubmitReset: (email, code, newPassword) async {
                      return await _authService.resetPassword(email, code, newPassword);
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.mail_outline),
            label: Text(loc.t('sign_in_email')),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignUpPage(
                    onSubmit: (displayName, email, password) async {
                      final user = await _authService.signUp(displayName, email, password);
                      if (user != null) {
                        widget.onUserUpdated(user);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Регистрация успешна')),
                        );
                        setState(() {
                          _user = user;
                        });
                        return null;
                      } else {
                        return 'Ошибка регистрации';
                      }
                    },
                    onGoogleSignIn: () async {
                      await widget.onGoogleSignIn();
                      return null;
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: Text(loc.t('create_account')),
          ),
        ),
        const SizedBox(height: 12),
       
      ],
    );
  }

  Widget _historyAndAbout(ThemeData theme, AppLocalizations loc) {
    if (!isSignedIn) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Text(
          loc.t('sign_in_to_view_history'),
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.library_books_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.t('saved_transcripts'),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.t('history_info'),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _isLoadingHistory
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _historyCount.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _historyCount == 0 ? null : _clearHistory,
              icon: const Icon(Icons.delete_outline),
              label: Text(loc.t('clear_history')),
            ),
          ),
        ],
      ),
    );
  }


  Widget _languageSelector(ThemeData theme, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('language'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onLanguageChanged(const Locale('en')),
                  child: const Text('English'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onLanguageChanged(const Locale('ru')),
                  child: const Text('Русский'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

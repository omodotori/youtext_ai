import 'package:flutter/material.dart';
import '../models/app_user.dart';

import '../l10n.dart';
import 'edit_profile_page.dart';
import '../pages/auth/sign_in_page.dart';
import '../pages/auth/sign_up_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.tabIndex,
    required this.onTabSelected,
    required this.historyCount,
    required this.isSignedIn,
    required this.isAuthenticating,
    required this.user,
    required this.onEmailSignIn,
    required this.onEmailSignUp,
    required this.onGoogleSignIn,
    required this.onSignOut,
    required this.onClearHistory,
    required this.onLanguageChanged,
  });

  final int tabIndex;
  final ValueChanged<int> onTabSelected;
  final int historyCount;
  final bool isSignedIn;
  final bool isAuthenticating;
  final AppUser? user;
  final Future<void> Function() onEmailSignIn;
  final Future<void> Function() onEmailSignUp;
  final Future<void> Function() onGoogleSignIn;
  final VoidCallback onSignOut;
  final VoidCallback onClearHistory;
  final void Function(Locale) onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final displayName = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName
        : loc.t('youtext_user');
    final email = user?.email;
    final initials =
        (displayName.isNotEmpty ? displayName[0] : 'Y').toUpperCase();

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
                  gradient: user?.photoUrl == null
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
                child: user?.photoUrl != null
                    ? CircleAvatar(
                        radius: 44,
                        backgroundImage: NetworkImage(user!.photoUrl!),
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
                  builder: (context) => EditProfilePage(user: user),
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
            onPressed: onSignOut,
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
        // Email Sign-In → открывает SignInPage
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
                      await onEmailSignIn();
                      return null;
                    },
                    onGoogleSignIn: () async {
                      await onGoogleSignIn();
                      return null;
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

        // Sign-Up  открывает SignUpPage
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
                      await onEmailSignUp();
                      return null;
                    },
                    onGoogleSignIn: () async {
                      await onGoogleSignIn();
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

        // Google Sign-In
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: onGoogleSignIn,
            icon: const Icon(Icons.g_mobiledata),
            label: Text(loc.t('continue_google')),
          ),
        ),
      ],
    );
  }



  Widget _historyAndAbout(ThemeData theme, AppLocalizations loc) {
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
              Icon(Icons.library_books_outlined,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.t('saved_transcripts'),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      loc.t('history_info'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(historyCount.toString(),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: historyCount == 0 ? null : onClearHistory,
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
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onLanguageChanged(const Locale('en')),
                  child: const Text('English'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onLanguageChanged(const Locale('ru')),
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
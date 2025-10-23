import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../widgets/page_header.dart';
import 'edit_profile_page.dart';


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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName
        : 'YouText user';
    final email = user?.email;
    final initials = (displayName.isNotEmpty ? displayName[0] : 'Y').toUpperCase();

    return ListView(
      key: const ValueKey('profile'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        PageHeader(
          title: 'Profile',
          tabIndex: tabIndex,
          onTabSelected: onTabSelected,
        ),
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
                isSignedIn ? displayName : 'Guest profile',
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
                _signedInButtons(context)
              else
                _signInOptions(context),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _historyAndAbout(theme),
      ],
    );
  }

  Widget _signedInButtons(BuildContext context) {
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
            label: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ),
      ],
    );
  }

  Widget _signInOptions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: isAuthenticating ? null : onGoogleSignIn,
            icon: isAuthenticating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.g_mobiledata),
            label: Text(isAuthenticating ? 'Connecting...' : 'Continue with Google'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: isAuthenticating ? null : onEmailSignIn,
            icon: const Icon(Icons.mail_outline),
            label: const Text('Sign in with email'),
          ),
        ),
        TextButton(
          onPressed: isAuthenticating ? null : onEmailSignUp,
          child: const Text('Create a new account'),
        ),
      ],
    );
  }

  Widget _historyAndAbout(ThemeData theme) {
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
                    Text('Saved transcripts',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'History is stored locally until you sign in.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(historyCount.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: historyCount == 0 ? null : onClearHistory,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear history'),
            ),
          ),
        ],
      ),
    );
  }
}
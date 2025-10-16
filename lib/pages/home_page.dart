import 'package:flutter/material.dart';

import '../models/transcription_record.dart';
import '../widgets/page_header.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.tabIndex,
    required this.onTabSelected,
    required this.urlController,
    required this.isProcessing,
    required this.progress,
    required this.lastResult,
    required this.history,
    required this.isSignedIn,
    required this.onStartTranscription,
    required this.onOpenResult,
    required this.onCopyRecord,
  });

  final int tabIndex;
  final ValueChanged<int> onTabSelected;
  final TextEditingController urlController;
  final bool isProcessing;
  final double progress;
  final TranscriptionRecord? lastResult;
  final List<TranscriptionRecord> history;
  final bool isSignedIn;
  final VoidCallback onStartTranscription;
  final void Function(TranscriptionRecord record) onOpenResult;
  final void Function(TranscriptionRecord record) onCopyRecord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = history.take(3).toList();

    return ListView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        PageHeader(
          title: 'Home',
          tabIndex: tabIndex,
          onTabSelected: onTabSelected,
        ),
        if (!isSignedIn) ...[
          const _GuestModeBanner(),
          const SizedBox(height: 20),
        ],
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
                controller: urlController,
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
                  onPressed: isProcessing ? null : onStartTranscription,
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
                    child: isProcessing
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
          child: isProcessing
              ? ProgressCard(progress: progress)
              : const SizedBox.shrink(key: ValueKey('progress-empty')),
        ),
        if (lastResult != null) ...[
          const SizedBox(height: 28),
          Text(
            'Latest transcription',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ResultCard(
            record: lastResult!,
            onOpen: () => onOpenResult(lastResult!),
            onCopy: () => onCopyRecord(lastResult!),
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
            HistoryTile(record: record, onTap: () => onOpenResult(record)),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _GuestModeBanner extends StatelessWidget {
  const _GuestModeBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_off_outlined,
              color: theme.colorScheme.primary, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transcribe without signing in. Sign in with Google later to back up projects and sync them.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = progress <= 0 ? null : progress.clamp(0.0, 1.0);
    final activeStep = clamped == null
        ? 0
        : clamped < 0.45
            ? 0
            : clamped < 0.9
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

    final headline = clamped == 1.0 ? 'All done!' : 'Processing your video';
    final subhead = clamped == 1.0
        ? 'Transcript saved to your history and ready to review.'
        : 'Feel free to explore other transcripts while we work in the background.';
    final leadingIcon =
        clamped == 1.0 ? Icons.check_circle_rounded : Icons.hourglass_top_rounded;

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
            value: clamped,
            backgroundColor: theme.colorScheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (var i = 0; i < stepIcons.length; i++) ...[
                Expanded(
                  child: _ProgressStep(
                    icon: stepIcons[i],
                    label: stepLabels[i],
                    isActive: !_isStepCompleted(clamped, i) && activeStep == i,
                    isCompleted: _isStepCompleted(clamped, i),
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

  static bool _isStepCompleted(double? value, int index) {
    if (value == null) return false;
    switch (index) {
      case 0:
        return value >= 0.45;
      case 1:
        return value >= 0.9;
      case 2:
        return value >= 1.0;
      default:
        return false;
    }
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = theme.colorScheme.primary;
    final inactive = theme.colorScheme.onSurface;
    final iconToShow = isCompleted ? Icons.check_rounded : icon;
    final iconColor = isCompleted || isActive ? highlight : inactive;
    final containerColor = isCompleted
        ? highlight.withAlpha(46)
        : isActive
            ? highlight.withAlpha(31)
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
            color: isCompleted || isActive ? theme.colorScheme.onSurface : inactive,
          ),
        ),
      ],
    );
  }
}

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
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

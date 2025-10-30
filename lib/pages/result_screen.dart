import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transcription_record.dart';
import '../l10n.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.record});

  final TranscriptionRecord record;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

enum _ContentView { transcript, outline, summary }

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _editController;
  late _ContentView _view;

  bool get _hasTranscript =>
      widget.record.transcript.trim().isNotEmpty || widget.record.lines.isNotEmpty;
  bool get _hasOutline => widget.record.highlights.isNotEmpty;
  bool get _hasSummary => widget.record.summary.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.record.transcript);
    _view = _initialView();
  }

  @override
  void didUpdateWidget(ResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record.id != widget.record.id) {
      _editController.text = widget.record.transcript;
      setState(() => _view = _initialView());
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  _ContentView _initialView() {
    if (_hasTranscript) return _ContentView.transcript;
    if (_hasSummary) return _ContentView.summary;
    if (_hasOutline) return _ContentView.outline;
    return _ContentView.transcript;
  }

  bool get _canCopy {
    switch (_view) {
      case _ContentView.transcript:
        return _hasTranscript;
      case _ContentView.outline:
        return _hasOutline;
      case _ContentView.summary:
        return _hasSummary;
    }
  }

  void _copyCurrent() {
    final l10n = AppLocalizations.of(context);
    switch (_view) {
      case _ContentView.transcript:
        if (!_hasTranscript) {
          _showSnack(l10n.t('no_transcript_available'));
          return;
        }
        Clipboard.setData(ClipboardData(text: _editController.text));
        _showSnack(l10n.t('transcript_copied'));
        break;
      case _ContentView.outline:
        if (!_hasOutline) {
          _showSnack(l10n.t('no_highlights_available'));
          return;
        }
        final bulletList =
            widget.record.highlights.map((item) => '- $item').join('\n');
        Clipboard.setData(ClipboardData(text: bulletList));
        _showSnack(l10n.t('highlights_copied'));
        break;
      case _ContentView.summary:
        if (!_hasSummary) {
          _showSnack(l10n.t('no_summary_available'));
          return;
        }
        Clipboard.setData(ClipboardData(text: widget.record.summary));
        _showSnack(l10n.t('summary_copied'));
        break;
    }
  }

  void _copyLine(TranscriptLine line) {
    Clipboard.setData(ClipboardData(text: '[${line.timestamp}] ${line.text}'));
    _showSnack(AppLocalizations.of(context).t('line_copied'));
  }

  void _openEditor() {
    final l10n = AppLocalizations.of(context);
    if (!_hasTranscript) {
      _showSnack(l10n.t('no_transcript_available'));
      return;
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('quick_edit_transcript'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _editController,
                maxLines: 12,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.t('edit_here'),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.t('done')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.record.videoTitle)),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'copy',
            onPressed: _canCopy ? _copyCurrent : null,
            icon: const Icon(Icons.copy_all_rounded),
            label: Text(_copyButtonLabel(l10n)),
          ),
          if (_view == _ContentView.transcript && _hasTranscript) ...[
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'edit',
              onPressed: _openEditor,
              child: const Icon(Icons.edit_outlined),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Text(l10n.t('source_video'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(
            widget.record.videoUrl,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          _ContentSelector(
            current: _view,
            onChanged: (value) => setState(() => _view = value),
            hasTranscript: _hasTranscript,
            hasOutline: _hasOutline,
            hasSummary: _hasSummary,
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildContent(theme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations l10n) {
    switch (_view) {
      case _ContentView.transcript:
        return _buildUnavailableState(theme,
            key: const ValueKey('transcript-empty'),
            icon: Icons.article_outlined,
            title: l10n.t('no_transcript'),
            message: l10n.t('enable_transcript_message'));
      case _ContentView.outline:
        return _buildUnavailableState(theme,
            key: const ValueKey('outline-empty'),
            icon: Icons.list_alt_rounded,
            title: l10n.t('no_outline'),
            message: l10n.t('enable_summary_message'));
      case _ContentView.summary:
        return _buildUnavailableState(theme,
            key: const ValueKey('summary-empty'),
            icon: Icons.bolt_outlined,
            title: l10n.t('no_summary'),
            message: l10n.t('enable_summary_message'));
    }
  }

  Widget _buildUnavailableState(
    ThemeData theme, {
    required Key key,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 26),
          const SizedBox(height: 12),
          Text(title,
              style:
                  theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _copyButtonLabel(AppLocalizations l10n) {
    switch (_view) {
      case _ContentView.transcript:
        return l10n.t('copy_transcript');
      case _ContentView.outline:
        return l10n.t('copy_highlights');
      case _ContentView.summary:
        return l10n.t('copy_summary');
    }
  }
}

class _ContentSelector extends StatelessWidget {
  const _ContentSelector({
    required this.current,
    required this.onChanged,
    required this.hasTranscript,
    required this.hasOutline,
    required this.hasSummary,
  });

  final _ContentView current;
  final ValueChanged<_ContentView> onChanged;
  final bool hasTranscript;
  final bool hasOutline;
  final bool hasSummary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: _ContentView.values.map((view) {
        final enabled = switch (view) {
          _ContentView.transcript => hasTranscript,
          _ContentView.outline => hasOutline,
          _ContentView.summary => hasSummary,
        };
        final selected = current == view;
        return ChoiceChip(
          label: Text(_label(view, l10n)),
          avatar: Icon(_icon(view), size: 18),
          selected: selected,
          onSelected: enabled ? (_) => onChanged(view) : null,
        );
      }).toList(),
    );
  }

  String _label(_ContentView view, AppLocalizations l10n) {
    switch (view) {
      case _ContentView.transcript:
        return l10n.t('transcript');
      case _ContentView.outline:
        return l10n.t('highlights');
      case _ContentView.summary:
        return l10n.t('summary');
    }
  }

  IconData _icon(_ContentView view) {
    switch (view) {
      case _ContentView.transcript:
        return Icons.article_outlined;
      case _ContentView.outline:
        return Icons.list_alt_rounded;
      case _ContentView.summary:
        return Icons.bolt_outlined;
    }
  }
}
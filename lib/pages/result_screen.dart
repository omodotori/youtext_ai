import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/transcription_record.dart';

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
      setState(() {
        _view = _initialView();
      });
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
    switch (_view) {
      case _ContentView.transcript:
        if (!_hasTranscript) {
          _showSnack('Transcript is not available for this run.');
          return;
        }
        Clipboard.setData(ClipboardData(text: _editController.text));
        _showSnack('Transcript copied to clipboard.');
        break;
      case _ContentView.outline:
        if (!_hasOutline) {
          _showSnack('Highlights are not available for this run.');
          return;
        }
        final bulletList =
            widget.record.highlights.map((item) => '- $item').join('\n');
        Clipboard.setData(ClipboardData(text: bulletList));
        _showSnack('Highlights copied to clipboard.');
        break;
      case _ContentView.summary:
        if (!_hasSummary) {
          _showSnack('Summary is not available for this run.');
          return;
        }
        Clipboard.setData(ClipboardData(text: widget.record.summary));
        _showSnack('Summary copied to clipboard.');
        break;
    }
  }

  void _copyLine(TranscriptLine line) {
    Clipboard.setData(ClipboardData(text: '[${line.timestamp}] ${line.text}'));
    _showSnack('Line copied to clipboard.');
  }

  void _openEditor() {
    if (!_hasTranscript) {
      _showSnack('Transcript is not available for this run.');
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
                'Quick edit transcript',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _editController,
                maxLines: 12,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
            onPressed: _canCopy ? _copyCurrent : null,
            icon: const Icon(Icons.copy_all_rounded),
            label: Text(_copyButtonLabel()),
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
          Text('Source video', style: theme.textTheme.titleMedium),
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
            child: _buildContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    switch (_view) {
      case _ContentView.transcript:
        return _buildTranscriptView(theme);
      case _ContentView.outline:
        return _buildOutlineView(theme);
      case _ContentView.summary:
        return _buildSummaryView(theme);
    }
  }

  Widget _buildTranscriptView(ThemeData theme) {
    if (!_hasTranscript) {
      return _buildUnavailableState(
        theme,
        key: const ValueKey('transcript-empty'),
        icon: Icons.article_outlined,
        title: 'Transcript not generated',
        message:
            'Enable transcript generation on the Home tab and run the transcription again.',
      );
    }

    final lines = widget.record.lines;
    if (lines.isEmpty) {
      if (_editController.text.trim().isEmpty) {
        return _buildUnavailableState(
          theme,
          key: const ValueKey('transcript-missing'),
          icon: Icons.hourglass_empty_rounded,
          title: 'No transcript lines',
          message: 'No text was captured for this run.',
        );
      }
      return Container(
        key: const ValueKey('transcript-single'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: SelectableText(
          _editController.text,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      );
    }

    return Column(
      key: const ValueKey('transcript'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) ...[
          InkWell(
            onTap: () => _copyLine(line),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    child: SelectableText(
                      line.text,
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: 'Copy line',
                    onPressed: () => _copyLine(line),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildOutlineView(ThemeData theme) {
    if (!_hasOutline) {
      return _buildUnavailableState(
        theme,
        key: const ValueKey('outline-empty'),
        icon: Icons.list_alt_rounded,
        title: 'Highlights not generated',
        message:
            'Enable summary generation on the Home tab to see key bullet points.',
      );
    }

    return Column(
      key: const ValueKey('outline'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final note in widget.record.highlights) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('- ', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Expanded(
                  child: SelectableText(
                    note,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildSummaryView(ThemeData theme) {
    if (!_hasSummary) {
      return _buildUnavailableState(
        theme,
        key: const ValueKey('summary-empty'),
        icon: Icons.bolt_outlined,
        title: 'Summary not generated',
        message:
            'Turn on summary generation to get a short recap of each transcription.',
      );
    }

    return Container(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SelectableText(
        widget.record.summary,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
    );
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
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 26),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
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

  String _copyButtonLabel() {
    switch (_view) {
      case _ContentView.transcript:
        return 'Copy transcript';
      case _ContentView.outline:
        return 'Copy highlights';
      case _ContentView.summary:
        return 'Copy summary';
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
          label: Text(_label(view)),
          avatar: Icon(_icon(view), size: 18),
          selected: selected,
          onSelected: enabled ? (_) => onChanged(view) : null,
        );
      }).toList(),
    );
  }

  String _label(_ContentView view) {
    switch (view) {
      case _ContentView.transcript:
        return 'Transcript';
      case _ContentView.outline:
        return 'Highlights';
      case _ContentView.summary:
        return 'Summary';
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

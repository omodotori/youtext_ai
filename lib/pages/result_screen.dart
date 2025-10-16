import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/transcription_record.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.record});

  final TranscriptionRecord record;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.record.transcript);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _editController.text));
    _showSnack('Transcript copied to clipboard.');
  }

  void _copyLine(TranscriptLine line) {
    Clipboard.setData(ClipboardData(text: '[${line.timestamp}] ${line.text}'));
    _showSnack('Line copied.');
  }

  void _openEditor() {
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
            children: [
              Text(
                'Edit transcript',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _editController,
                maxLines: 12,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            onPressed: _copyAll,
            icon: const Icon(Icons.copy_all_rounded),
            label: const Text('Copy all'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'edit',
            onPressed: _openEditor,
            child: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Text('Source', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(
            widget.record.videoUrl,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text('Summary', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(widget.record.summary, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text('Transcript', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final line in widget.record.lines) ...[
            InkWell(
              onTap: () => _copyLine(line),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                      child: Text(
                        line.text,
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

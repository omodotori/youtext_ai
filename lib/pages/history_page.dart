import 'package:flutter/material.dart';
import '../models/transcription_record.dart';
import '../l10n.dart';
import '../services/history_service.dart';

// 🔹 Добавляем enum для вариантов сортировки
enum SortOption { newest, oldest, aToZ, zToA }

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
    required this.tabIndex,
    required this.onTabSelected,
    required this.isSignedIn,
    required this.onOpenRecord,
    required this.onDeleteRecord,
  });

  final int tabIndex;
  final ValueChanged<int> onTabSelected;
  final bool isSignedIn;
  final void Function(TranscriptionRecord record) onOpenRecord;
  final void Function(TranscriptionRecord record) onDeleteRecord;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  List<TranscriptionRecord> _history = [];
  bool _isLoading = true;

  // 🔹 Для поиска
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // 🔹 Состояние для текущей сортировки (по умолчанию: сначала новые)
  SortOption _sortOption = SortOption.newest;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // 🔹 1. Фильтруем историю по поиску
    final filteredHistory = _history.where((record) {
      final query = _searchQuery.toLowerCase();
      return record.videoTitle.toLowerCase().contains(query) ||
          (record.summary?.toLowerCase().contains(query) ?? false);
    }).toList();

    // 🔹 2. Применяем сортировку к отфильтрованному списку
    filteredHistory.sort((a, b) {
      switch (_sortOption) {
        case SortOption.newest:
          return b.createdAt.compareTo(a.createdAt);
        case SortOption.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case SortOption.aToZ:
          return a.videoTitle.toLowerCase().compareTo(b.videoTitle.toLowerCase());
        case SortOption.zToA:
          return b.videoTitle.toLowerCase().compareTo(a.videoTitle.toLowerCase());
      }
    });

    if (_history.isEmpty) {
      return ListView(
        key: const ValueKey('history-empty'),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: theme.colorScheme.primary.withAlpha(38),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.hourglass_empty_rounded,
                    color: theme.colorScheme.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.noTranscriptionsYet,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.dropLinkToStart,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (!widget.isSignedIn) ...[
                  const SizedBox(height: 20),
                  Text(
                    l10n.signInToBackup,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => widget.onTabSelected(0),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(l10n.goToHome),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      key: const ValueKey('history'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        // 🔹 3. Поле поиска и кнопка сортировки в одном Row
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transcripts', // можно позже заменить на локализацию
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: PopupMenuButton<SortOption>(
                  icon: const Icon(Icons.sort_rounded),
                  tooltip: 'Sort by',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (SortOption result) {
                    setState(() {
                      _sortOption = result;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
                    const PopupMenuItem<SortOption>(
                      value: SortOption.newest,
                      child: Text('Newest first'), 
                    ),
                    const PopupMenuItem<SortOption>(
                      value: SortOption.oldest,
                      child: Text('Oldest first'),
                    ),
                    const PopupMenuItem<SortOption>(
                      value: SortOption.aToZ,
                      child: Text('A to Z'),
                    ),
                    const PopupMenuItem<SortOption>(
                      value: SortOption.zToA,
                      child: Text('Z to A'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (!widget.isSignedIn) ...[
          const _HistoryHintBanner(),
          const SizedBox(height: 16),
        ],

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: theme.colorScheme.primary.withAlpha(38),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.library_books_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.transcriptLibrary,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_history.length} ${_history.length == 1 ? l10n.clip : l10n.clips} — ${l10n.swipeToDelete}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 🔹 Выводим отфильтрованный и отсортированный список
        for (final record in filteredHistory) ...[
          Dismissible(
            key: ValueKey(record.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            onDismissed: (_) async {
              await _historyService.deleteRecord(record.id);
              setState(() {
                _history.removeWhere((r) => r.id == record.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Удалено ${record.videoTitle}')),
              );
            },
            child: HistoryTile(
              record: record,
              onTap: () => widget.onOpenRecord(record),
            ),
          ),
          if (record != filteredHistory.last) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.record, required this.onTap});

  final TranscriptionRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final localDate = record.createdAt.toLocal();
    final formattedDate = formatDate(localDate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.videoTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (record.summary != null && record.summary!.isNotEmpty) ...[
                      Text(
                        record.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryHintBanner extends StatelessWidget {
  const _HistoryHintBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
          Icon(Icons.cloud_upload_outlined,
              color: theme.colorScheme.primary, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.keepYourTranscripts,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.keepYourTranscriptsDesc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final now = DateTime.now();
  final monthLabel = months[date.month - 1];
  final yearSuffix = date.year == now.year ? '' : ', ${date.year}';
  return '$monthLabel ${date.day}$yearSuffix';
}
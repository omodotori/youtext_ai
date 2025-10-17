class TranscriptionRecord {
  const TranscriptionRecord({
    required this.id,
    required this.videoTitle,
    required this.videoUrl,
    required this.createdAt,
    required this.transcript,
    required this.lines,
    required this.summary,
    required this.highlights,
  });

  final String id;
  final String videoTitle;
  final String videoUrl;
  final DateTime createdAt;
  final String transcript;
  final List<TranscriptLine> lines;
  final String summary;
  final List<String> highlights;
}

class TranscriptLine {
  const TranscriptLine({required this.timestamp, required this.text});

  final String timestamp;
  final String text;
}

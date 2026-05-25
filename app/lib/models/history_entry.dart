import '../models/reply.dart';

class HistoryEntry {
  final String message;
  final List<ReplyResult> replies;
  final DateTime timestamp;

  HistoryEntry({
    required this.message,
    required this.replies,
    required this.timestamp,
  });
}

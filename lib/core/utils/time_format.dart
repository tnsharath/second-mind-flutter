import 'package:intl/intl.dart';

/// Human-friendly relative timestamps ("5 min ago", "yesterday").
String formatRelative(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  return DateFormat('MMM d').format(time);
}

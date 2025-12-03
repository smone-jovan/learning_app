import '../utils/date_formatter.dart';

/// DateTime extensions
extension DateTimeExtension on DateTime {
  // Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  // Format to readable string
  String format([String pattern = 'dd MMM yyyy']) {
    return DateFormatter.format(this, pattern: pattern);
  }

  // Get relative time
  String get timeAgo {
    return DateFormatter.getRelativeTime(this);
  }

  // Check if same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

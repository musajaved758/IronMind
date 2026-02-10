import 'package:flutter_riverpod/legacy.dart';

/// Provider for the bottom navigation bar index
final navIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for the selected calendar date
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Helper to check if a date is today
bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

/// Helper to check if a date is in the future
bool isFuture(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  return target.isAfter(today);
}

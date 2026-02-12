import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';

/// Provider for the bottom navigation bar index
final navIndexProvider = StateProvider<int>((ref) => 0);
final swapHomeAndChallengeProvider = StateProvider<bool>((ref) => false);
final showHabitCalendarProvider = StateProvider<bool>((ref) => true);
final maxChallengesProvider = StateProvider<int>((ref) => 5);

/// Whether any challenge has phases/roadmap — controls Phases tab visibility
final hasAnyPhasesProvider = Provider<bool>((ref) {
  final challenges = ref.watch(challengeProvider);
  return challenges.any((c) => !c.isCompleted && c.roadmap.isNotEmpty);
});

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

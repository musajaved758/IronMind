import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:iron_mind/features/challenge/data/models/challenge_model.dart';

class ChallengeIntelStats {
  final int totalChallenges;
  final int completedChallenges;
  final int ongoingChallenges;
  final double overallCompletionRate;
  final Map<DateTime, int>
  completionHistory; // Date -> count of challenges completed that day
  final Map<DateTime, int>
  monthlyProgress; // Date -> count of challenges completed
  final List<ChallengeModel> activeChallenges;
  final List<ChallengeModel> allChallenges;
  final int bestCurrentStreak;
  final int bestLongestStreak;

  ChallengeIntelStats({
    required this.totalChallenges,
    required this.completedChallenges,
    required this.ongoingChallenges,
    required this.overallCompletionRate,
    required this.completionHistory,
    required this.monthlyProgress,
    required this.activeChallenges,
    required this.allChallenges,
    required this.bestCurrentStreak,
    required this.bestLongestStreak,
  });
}

final challengeStatsProvider = Provider<ChallengeIntelStats>((ref) {
  final challenges = ref.watch(challengeProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final ongoing = challenges.where((c) {
    final endDate = c.startDate.add(Duration(days: c.duration));
    return c.startDate.isBefore(now) && endDate.isAfter(now);
  }).toList();

  final completed = challenges.where((c) {
    final endDate = c.startDate.add(Duration(days: c.duration));
    // A challenge is "fully completed" if the end date has passed.
    return endDate.isBefore(now) || endDate.isAtSameMomentAs(now);
  }).toList();

  // History for progress over time (last 30 days)
  final Map<DateTime, int> history = {};
  for (int i = 0; i < 30; i++) {
    final date = today.subtract(Duration(days: i));
    int count = 0;
    for (final c in challenges) {
      if (c.isCompletedOn(date)) count++;
    }
    history[date] = count;
  }

  // Monthly Progress (Current Month)
  final Map<DateTime, int> monthlyProgress = {};
  final startOfMonth = DateTime(now.year, now.month, 1);
  final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

  for (int i = 0; i < daysInMonth; i++) {
    final date = startOfMonth.add(Duration(days: i));
    int count = 0;
    for (final c in challenges) {
      if (c.isCompletedOn(date)) count++;
    }
    monthlyProgress[date] = count;
  }

  double totalProgress = 0;
  if (challenges.isNotEmpty) {
    for (final c in challenges) {
      totalProgress += c.progress;
    }
  }

  int bestCurrent = 0;
  int bestLongest = 0;
  for (final c in challenges) {
    if (c.currentStreak > bestCurrent) bestCurrent = c.currentStreak;
    if (c.longestStreak > bestLongest) bestLongest = c.longestStreak;
  }

  return ChallengeIntelStats(
    totalChallenges: challenges.length,
    completedChallenges: completed.length,
    ongoingChallenges: ongoing.length,
    overallCompletionRate: challenges.isEmpty
        ? 0
        : totalProgress / challenges.length,
    completionHistory: history,
    monthlyProgress: monthlyProgress,
    activeChallenges: ongoing,
    allChallenges: challenges,
    bestCurrentStreak: bestCurrent,
    bestLongestStreak: bestLongest,
  );
});

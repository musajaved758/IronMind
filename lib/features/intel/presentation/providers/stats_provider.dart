import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/features/habit/presentation/providers/habit_provider.dart';
import 'package:iron_mind/features/habit/data/models/habit_model.dart';
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

class HabitIntelStats {
  final int totalHabits;
  final int completedToday;
  final int missedToday;
  final Map<DateTime, int> weeklyTrend; // Last 7 days trend
  final List<HabitDetailStats> habitDetails;
  final int bestCurrentStreak;
  final int bestLongestStreak;
  final List<HabitModel> allHabits;

  HabitIntelStats({
    required this.totalHabits,
    required this.completedToday,
    required this.missedToday,
    required this.weeklyTrend,
    required this.habitDetails,
    required this.bestCurrentStreak,
    required this.bestLongestStreak,
    required this.allHabits,
  });
}

class HabitDetailStats {
  final String id;
  final String name;
  final double completionRate;
  final int currentStreak;
  final int bestStreak;

  HabitDetailStats({
    required this.id,
    required this.name,
    required this.completionRate,
    required this.currentStreak,
    required this.bestStreak,
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
    // However, progress can also be 1.0. Let's define it as end date passed.
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

final habitStatsProvider = Provider<HabitIntelStats>((ref) {
  final habits = ref.watch(habitProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int completedToday = 0;
  for (final h in habits) {
    if (h.isCompletedOn(today)) completedToday++;
  }

  final Map<DateTime, int> weeklyTrend = {};
  for (int i = 0; i < 7; i++) {
    final date = today.subtract(Duration(days: i));
    int count = 0;
    for (final h in habits) {
      if (h.isCompletedOn(date)) count++;
    }
    weeklyTrend[date] = count;
  }

  final List<HabitDetailStats> habitDetails = habits.map((h) {
    // Completion rate = days completed / days since creation
    final daysSinceCreation = today.difference(h.createdAt).inDays + 1;
    final rate = h.completedDates.length / daysSinceCreation;

    // Streak calculation
    int streak = 0;
    DateTime checkDate = today;
    // If not completed today, start checking from yesterday
    if (!h.isCompletedOn(today)) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (h.isCompletedOn(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return HabitDetailStats(
      id: h.id,
      name: h.name,
      completionRate: rate.clamp(0.0, 1.0),
      currentStreak: streak,
      bestStreak: h.longestStreak,
    );
  }).toList();

  int bestHabitCurrent = 0;
  int bestHabitLongest = 0;
  for (final detail in habitDetails) {
    if (detail.currentStreak > bestHabitCurrent)
      bestHabitCurrent = detail.currentStreak;
    if (detail.bestStreak > bestHabitLongest)
      bestHabitLongest = detail.bestStreak;
  }

  return HabitIntelStats(
    totalHabits: habits.length,
    completedToday: completedToday,
    missedToday: habits.length - completedToday,
    weeklyTrend: weeklyTrend,
    habitDetails: habitDetails,
    bestCurrentStreak: bestHabitCurrent,
    bestLongestStreak: bestHabitLongest,
    allHabits: habits,
  );
});

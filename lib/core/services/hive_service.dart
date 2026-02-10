import 'package:hive_flutter/hive_flutter.dart';
import '../../features/habit/data/models/habit_model.dart';
import '../../features/challenge/data/models/challenge_model.dart';
/*
  Crucial: Ensure 'flutter pub run build_runner build' is run to generate
  the HabitModelAdapter.
*/

class HiveService {
  static const String habitBoxName = 'habits';
  static const String challengeBoxName = 'challenges';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Register Adapters
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(ChallengeSubtaskAdapter());
    Hive.registerAdapter(ChallengeMilestoneAdapter());
    Hive.registerAdapter(ChallengeModelAdapter());
    // Open Boxes
    await Hive.openBox<HabitModel>(habitBoxName);
    await Hive.openBox<ChallengeModel>(challengeBoxName);
  }

  static Box<HabitModel> get habitBox => Hive.box<HabitModel>(habitBoxName);
  static Box<ChallengeModel> get challengeBox =>
      Hive.box<ChallengeModel>(challengeBoxName);

  static Future<void> saveHabit(HabitModel habit) async {
    await habitBox.put(habit.id, habit);
  }

  static List<HabitModel> getHabits() {
    return habitBox.values.toList();
  }

  static Future<void> updateHabit(HabitModel habit) async {
    await habitBox.put(habit.id, habit);
  }

  static Future<void> deleteHabit(String id) async {
    await habitBox.delete(id);
  }

  /// Mark habit as completed for today (or specific date)
  static Future<void> toggleHabitCompletion(
    String habitId,
    DateTime date,
  ) async {
    final habit = habitBox.get(habitId);
    if (habit != null) {
      final isCompleted = habit.isCompletedOn(date);
      List<DateTime> newDates = List.from(habit.completedDates);

      if (isCompleted) {
        newDates.removeWhere(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        );
      } else {
        newDates.add(date);
      }

      final updatedHabit = habit.copyWith(completedDates: newDates);
      await updateHabit(updatedHabit);
    }
  }

  // Challenge Methods
  static List<ChallengeModel> getChallenges() {
    return challengeBox.values.toList();
  }

  static Future<void> saveChallenge(ChallengeModel challenge) async {
    await challengeBox.put(challenge.id, challenge);
  }

  static Future<void> updateChallenge(ChallengeModel challenge) async {
    await challengeBox.put(challenge.id, challenge);
  }

  static Future<void> deleteChallenge(String id) async {
    await challengeBox.delete(id);
  }

  static Future<void> toggleChallengeCompletion(
    String challengeId,
    DateTime date,
  ) async {
    final challenge = challengeBox.get(challengeId);
    if (challenge != null) {
      final isCompleted = challenge.isCompletedOn(date);
      List<DateTime> newDates = List.from(challenge.completedDates);

      if (isCompleted) {
        newDates.removeWhere(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        );
      } else {
        newDates.add(date);
      }

      final updatedChallenge = challenge.copyWith(completedDates: newDates);
      await updateChallenge(updatedChallenge);
    }
  }
}

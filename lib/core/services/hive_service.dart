import 'package:hive_flutter/hive_flutter.dart';
import '../../features/habit/data/models/habit_model.dart';
/*
  Crucial: Ensure 'flutter pub run build_runner build' is run to generate
  the HabitModelAdapter.
*/

class HiveService {
  static const String habitBoxName = 'habits';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Register Adapter
    Hive.registerAdapter(HabitModelAdapter());
    // Open Box
    await Hive.openBox<HabitModel>(habitBoxName);
  }

  static Box<HabitModel> get habitBox => Hive.box<HabitModel>(habitBoxName);

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
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operation_brotherhood/features/habit/data/models/habit_model.dart';
import 'package:operation_brotherhood/core/services/hive_service.dart';
import 'package:uuid/uuid.dart';

final habitProvider = NotifierProvider<HabitNotifier, List<HabitModel>>(
  HabitNotifier.new,
);

class HabitNotifier extends Notifier<List<HabitModel>> {
  @override
  List<HabitModel> build() {
    return HiveService.getHabits();
  }

  Future<void> addHabit(String name) async {
    final newHabit = HabitModel(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    await HiveService.saveHabit(newHabit);
    ref.invalidateSelf(); // Or manually update state
    // state = [...state, newHabit];
  }

  Future<void> toggleCompletion(String habitId, DateTime date) async {
    await HiveService.toggleHabitCompletion(habitId, date);
    ref.invalidateSelf();
  }
}

import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final List<DateTime> completedDates;

  @HiveField(4, defaultValue: 'Other')
  final String category;

  @HiveField(5, defaultValue: 'DAILY')
  final String frequency;

  @HiveField(6, defaultValue: 1)
  final int targetValue;

  @HiveField(7, defaultValue: 'TIMES')
  final String targetUnit;

  @HiveField(8)
  final DateTime? reminderTime;

  @HiveField(9, defaultValue: 'MEDIUM')
  final String priority;

  @HiveField(10, defaultValue: '')
  final String motivationNote;

  @HiveField(11)
  final DateTime endDate;

  @HiveField(12)
  final int categoryIcon;

  HabitModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.endDate,
    this.completedDates = const [],
    this.category = 'Other',
    this.categoryIcon = 0xe24a, // Default icon (Icons.fitness_center)
    this.frequency = 'DAILY',
    this.targetValue = 1,
    this.targetUnit = 'TIMES',
    this.reminderTime,
    this.priority = 'MEDIUM',
    this.motivationNote = '',
  });

  bool isCompletedOn(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  int get duration {
    final start = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.difference(start).inDays + 1;
  }

  int get daysElapsed {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    return difference >= 0 ? difference : 0;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final remaining = end.difference(today).inDays;
    return remaining >= 0 ? remaining : 0;
  }

  double get progress {
    if (duration == 0) return 0.0;
    return completedDates.length / duration;
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final uniqueDates =
        completedDates
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

    if (uniqueDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    final lastCompleted = uniqueDates.last;

    if (!lastCompleted.isAtSameMomentAs(todayDate) &&
        !lastCompleted.isAtSameMomentAs(yesterdayDate)) {
      return 0;
    }

    int streak = 1;
    for (int i = uniqueDates.length - 1; i > 0; i--) {
      final current = uniqueDates[i];
      final prev = uniqueDates[i - 1];
      if (current.difference(prev).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    if (completedDates.isEmpty) return 0;

    final uniqueDates =
        completedDates
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

    if (uniqueDates.isEmpty) return 0;

    int longest = 1;
    int current = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      if (uniqueDates[i].difference(uniqueDates[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  HabitModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? endDate,
    List<DateTime>? completedDates,
    String? category,
    int? categoryIcon,
    String? frequency,
    int? targetValue,
    String? targetUnit,
    DateTime? reminderTime,
    String? priority,
    String? motivationNote,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      endDate: endDate ?? this.endDate,
      completedDates: completedDates ?? this.completedDates,
      category: category ?? this.category,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      frequency: frequency ?? this.frequency,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      motivationNote: motivationNote ?? this.motivationNote,
    );
  }
}

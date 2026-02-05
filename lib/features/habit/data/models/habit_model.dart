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

  HabitModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.completedDates = const [],
  });

  bool isCompletedOn(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  HabitModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<DateTime>? completedDates,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}

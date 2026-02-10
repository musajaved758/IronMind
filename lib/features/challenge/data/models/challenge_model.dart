import 'package:hive/hive.dart';

part 'challenge_model.g.dart';

@HiveType(typeId: 3)
class ChallengeSubtask {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  ChallengeSubtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  ChallengeSubtask copyWith({String? id, String? title, bool? isCompleted}) {
    return ChallengeSubtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@HiveType(typeId: 2)
class ChallengeMilestone {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int durationDays;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(6)
  final List<ChallengeSubtask> subtasks;

  ChallengeMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    this.isCompleted = false,
    this.subtasks = const [],
  });

  ChallengeMilestone copyWith({
    String? id,
    String? title,
    String? description,
    int? durationDays,
    bool? isCompleted,
    List<ChallengeSubtask>? subtasks,
  }) {
    return ChallengeMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationDays: durationDays ?? this.durationDays,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}

@HiveType(typeId: 1)
class ChallengeModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int duration; // in days

  @HiveField(3)
  final String threatLevel; // EASY, MEDIUM, HARD

  @HiveField(4)
  final String consequenceType; // DONATE, PHYSICAL

  @HiveField(5)
  final String specificConsequence; // COLD SHOWER, PUSHUPS (50), etc.

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final List<DateTime> completedDates;

  @HiveField(8)
  final List<ChallengeMilestone> roadmap;

  ChallengeModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.threatLevel,
    required this.consequenceType,
    required this.specificConsequence,
    required this.startDate,
    this.completedDates = const [],
    this.roadmap = const [],
  });

  bool isCompletedOn(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  int get daysElapsed {
    final now = DateTime.now();
    final difference = now.difference(startDate).inDays;
    return difference >= 0 ? difference : 0;
  }

  int get daysRemaining {
    final remaining = duration - daysElapsed;
    return remaining >= 0 ? remaining : 0;
  }

  double get progress {
    if (duration == 0) return 0.0;
    return completedDates.length / duration;
  }

  ChallengeModel copyWith({
    String? id,
    String? name,
    int? duration,
    String? threatLevel,
    String? consequenceType,
    String? specificConsequence,
    DateTime? startDate,
    List<DateTime>? completedDates,
    List<ChallengeMilestone>? roadmap,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      threatLevel: threatLevel ?? this.threatLevel,
      consequenceType: consequenceType ?? this.consequenceType,
      specificConsequence: specificConsequence ?? this.specificConsequence,
      startDate: startDate ?? this.startDate,
      completedDates: completedDates ?? this.completedDates,
      roadmap: roadmap ?? this.roadmap,
    );
  }
}

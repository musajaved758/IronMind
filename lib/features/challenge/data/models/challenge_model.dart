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

  bool get isCompleted {
    final endDate = startDate.add(Duration(days: duration));
    final now = DateTime.now();
    return now.isAfter(endDate);
  }

  int get daysElapsed {
    final now = DateTime.now();
    final difference = now.difference(startDate).inDays;
    // If it's the first day, difference is 0, so we return 1.
    return difference >= 0 ? difference + 1 : 1;
  }

  int get daysRemaining {
    final remaining =
        duration - (daysElapsed - 1); // -1 because daysElapsed is 1-based
    return remaining >= 0 ? remaining : 0;
  }

  double get progress {
    if (duration == 0) return 0.0;
    return completedDates.length / duration;
  }

  /// Returns the day range for a milestone (e.g. [1, 7])
  List<int> getMilestoneDayRange(int milestoneIndex) {
    if (milestoneIndex < 0 || milestoneIndex >= roadmap.length) return [];

    int startDay = 1;
    for (int i = 0; i < milestoneIndex; i++) {
      startDay += roadmap[i].durationDays;
    }
    int endDay = startDay + roadmap[milestoneIndex].durationDays - 1;
    return [startDay, endDay];
  }

  /// Checks if a milestone is completed based on the mission log
  bool isMilestoneCompleted(int milestoneIndex) {
    final range = getMilestoneDayRange(milestoneIndex);
    if (range.isEmpty) return false;

    final startDay = range[0];
    final endDay = range[1];

    // Total days in this milestone
    final totalDaysInMilestone = endDay - startDay + 1;

    // Count how many of these days are in completedDates
    int completedCount = 0;
    for (int day = startDay; day <= endDay; day++) {
      final targetDate = startDate.add(Duration(days: day - 1));
      if (isCompletedOn(targetDate)) {
        completedCount++;
      }
    }

    return completedCount == totalDaysInMilestone;
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

    // If the last completed date is neither today nor yesterday, streak is 0
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

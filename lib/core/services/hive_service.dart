import 'package:hive_flutter/hive_flutter.dart';
import '../../features/challenge/data/models/challenge_model.dart';

class HiveService {
  static const String challengeBoxName = 'challenges';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Register Adapters
    Hive.registerAdapter(ChallengeSubtaskAdapter());
    Hive.registerAdapter(ChallengeMilestoneAdapter());
    Hive.registerAdapter(ChallengeModelAdapter());
    // Open Boxes
    await Hive.openBox<ChallengeModel>(challengeBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<ChallengeModel> get challengeBox =>
      Hive.box<ChallengeModel>(challengeBoxName);

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

  // Settings Methods
  static Box get settingsBox => Hive.box(settingsBoxName);

  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }
}

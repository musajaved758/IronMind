import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/core/services/hive_service.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';

/// Provider for the bottom navigation bar index
final navIndexProvider = StateProvider<int>((ref) => 0);
final maxChallengesProvider = NotifierProvider<MaxChallengesNotifier, int>(
  MaxChallengesNotifier.new,
);

class MaxChallengesNotifier extends Notifier<int> {
  @override
  int build() {
    return HiveService.getSetting('max_challenges', defaultValue: 5);
  }

  void set(int value) {
    state = value;
    HiveService.saveSetting('max_challenges', value);
  }
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
      NotificationsEnabledNotifier.new,
    );

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    return HiveService.getSetting('notifications_enabled', defaultValue: true);
  }

  void set(bool value) {
    state = value;
    HiveService.saveSetting('notifications_enabled', value);
  }
}

final notificationTimeProvider =
    NotifierProvider<NotificationTimeNotifier, TimeOfDay>(
      NotificationTimeNotifier.new,
    );

class NotificationTimeNotifier extends Notifier<TimeOfDay> {
  @override
  TimeOfDay build() {
    final hour = HiveService.getSetting('notification_hour', defaultValue: 20);
    final minute = HiveService.getSetting(
      'notification_minute',
      defaultValue: 0,
    );
    return TimeOfDay(hour: hour, minute: minute);
  }

  void set(TimeOfDay time) {
    state = time;
    HiveService.saveSetting('notification_hour', time.hour);
    HiveService.saveSetting('notification_minute', time.minute);
  }
}

/// Whether any challenge has phases/roadmap — controls Phases tab visibility
final hasAnyPhasesProvider = Provider<bool>((ref) {
  final challenges = ref.watch(challengeProvider);
  return challenges.any((c) => !c.isCompleted && c.roadmap.isNotEmpty);
});

/// Provider for the selected calendar date
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Helper to check if a date is today
bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

/// Helper to check if a date is in the future
bool isFuture(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  return target.isAfter(today);
}

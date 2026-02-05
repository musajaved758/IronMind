import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/features/habit/presentation/providers/habit_provider.dart';
import 'package:operation_brotherhood/features/home/presentation/widgets/habit_card.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';

class HabitListView extends HookConsumerWidget {
  final DateTime selectedDate;

  const HabitListView({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);

    if (habits.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No habits added yet.\nTap + to add your first habit!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isCompleted = habit.isCompletedOn(selectedDate);

        // "Missed" logic: If date is in the past (before today) and not completed.
        final now = DateTime.now();
        final isPast = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ).isBefore(DateTime(now.year, now.month, now.day));

        final isMissed = isPast && !isCompleted;

        return HabitCard(
          isCompleted: isCompleted,
          onCompleteTap: (val) {
            ref
                .read(habitProvider.notifier)
                .toggleCompletion(habit.id, selectedDate);
          },
          title: habit.name,
          subTitle: isCompleted
              ? "Completed ✓"
              : (isMissed ? "Missed!" : "Pending"),
          icon: isCompleted
              ? Icons.check_circle
              : (isMissed ? Icons.cancel : Icons.radio_button_unchecked),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/habit/presentation/providers/habit_provider.dart';
import 'package:iron_mind/features/home/presentation/widgets/habit_card.dart';
import 'package:iron_mind/features/habit/presentation/screens/create_habit_screen.dart';
import 'package:iron_mind/features/habit/presentation/screens/habit_detail_screen.dart';

class HabitListView extends HookConsumerWidget {
  final DateTime selectedDate;

  const HabitListView({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final colors = Theme.of(context).appColors;

    final filteredHabits = habits.where((habit) {
      final date = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final startDate = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );
      final endDate = DateTime(
        habit.endDate.year,
        habit.endDate.month,
        habit.endDate.day,
      );

      final isInRange =
          (date.isAtSameMomentAs(startDate) || date.isAfter(startDate)) &&
          (date.isAtSameMomentAs(endDate) || date.isBefore(endDate));

      if (!isInRange) return false;

      if (habit.frequency == 'WEEKLY') {
        final isWeekend =
            date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
        if (!isWeekend) return false;
      }

      return true;
    }).toList();

    if (filteredHabits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No habits for this day.\nStay focused!",
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = filteredHabits[index];
        final isCompleted = habit.isCompletedOn(selectedDate);

        final now = DateTime.now();
        final selectedDateOnly = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );
        final todayOnly = DateTime(now.year, now.month, now.day);

        final isPast = selectedDateOnly.isBefore(todayOnly);
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
          categoryIcon: habit.categoryIcon,
          priority: habit.priority,
          motivationNote: habit.motivationNote,
          selectedDate: selectedDate,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(habit: habit),
              ),
            );
          },
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateHabitScreen(habitToEdit: habit),
              ),
            );
          },
          onDelete: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: colors.dialogBg,
                title: Text(
                  'Delete Habit',
                  style: TextStyle(color: colors.textPrimary),
                ),
                content: Text(
                  'Are you sure you want to delete this habit?',
                  style: TextStyle(color: colors.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(habitProvider.notifier).deleteHabit(habit.id);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.highPriorityColor),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

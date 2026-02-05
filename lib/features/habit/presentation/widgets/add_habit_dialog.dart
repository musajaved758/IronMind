import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/features/habit/presentation/providers/habit_provider.dart';

class AddHabitDialog extends HookConsumerWidget {
  const AddHabitDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();

    return AlertDialog(
      title: const Text('Add New Habit'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Enter habit name (e.g., Gym, Reading)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              ref.read(habitProvider.notifier).addHabit(controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

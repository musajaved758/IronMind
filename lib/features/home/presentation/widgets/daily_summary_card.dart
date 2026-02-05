import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/features/habit/presentation/providers/habit_provider.dart';
import 'package:intl/intl.dart';

class DailySummaryCard extends HookConsumerWidget {
  final DateTime selectedDate;

  const DailySummaryCard({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);

    // Calculate completed tasks for the selected date
    final completedTask = habits
        .where((habit) => habit.isCompletedOn(selectedDate))
        .length;
    final totalTask = habits.length;

    // Calculate efficiency percentage
    final efficiencyPercentage = totalTask > 0
        ? (completedTask / totalTask) * 100
        : 0.0;

    // Format date
    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

    // Determine status
    String status = "PENDING";
    Color statusColor = AppColors.glowingGreen;

    if (totalTask == 0) {
      status = "NO HABITS";
      statusColor = Colors.grey;
    } else if (completedTask == totalTask) {
      status = "COMPLETED";
      statusColor = AppColors.glowingGreen;
    } else if (completedTask > 0) {
      status = "IN PROGRESS";
      statusColor = AppColors.glowingGreen;
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate.toUpperCase(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Efficiency Percentage
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${efficiencyPercentage.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Efficiency",
                style: TextStyle(color: AppColors.textColorGrey, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalTask > 0 ? completedTask / totalTask : 0,
              minHeight: 12,
              backgroundColor: AppColors.cardBgUpColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.glowingGreen,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Footer Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.check_outlined,
                iconColor: AppColors.glowingGreen,
                value: '$completedTask / $totalTask',
                label: "COMPLETED",
              ),
              _buildStatItem(
                icon: Icons.hourglass_empty,
                iconColor: AppColors.glowingGreen,
                value: '${totalTask - completedTask}',
                label: "REMAINING",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for the bottom items
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

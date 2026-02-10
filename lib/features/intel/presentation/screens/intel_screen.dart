import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/features/intel/presentation/providers/stats_provider.dart';

class IntelScreen extends HookConsumerWidget {
  const IntelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedView = useState('CHALLENGES'); // 'CHALLENGES' or 'HABITS'

    return Scaffold(
      backgroundColor: AppColors.habitBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'INTEL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildToggle(selectedView),
          Expanded(
            child: selectedView.value == 'CHALLENGES'
                ? const _ChallengesView()
                : const _HabitsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(ValueNotifier<String> selectedView) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.habitSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: _toggleItem(
                'CHALLENGES',
                selectedView.value == 'CHALLENGES',
                () => selectedView.value = 'CHALLENGES',
              ),
            ),
            Expanded(
              child: _toggleItem(
                'HABITS',
                selectedView.value == 'HABITS',
                () => selectedView.value = 'HABITS',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.habitPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _ChallengesView extends HookConsumerWidget {
  const _ChallengesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(challengeStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('OVERALL CHALLENGE PROGRESS'),
          const SizedBox(height: 20),
          _buildRadialProgress(stats),
          const SizedBox(height: 40),
          _sectionHeader('STREAK & CONSISTENCY'),
          const SizedBox(height: 20),
          _buildConsistencyInsight(stats),
          const SizedBox(height: 40),
          _sectionHeader('PROGRESS OVER TIME'),
          const SizedBox(height: 20),
          _buildProgressChart(stats.completionHistory),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildRadialProgress(ChallengeIntelStats stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(
                        value: stats.overallCompletionRate * 100,
                        color: AppColors.habitPrimary,
                        radius: 12,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: (1 - stats.overallCompletionRate) * 100,
                        color: AppColors.habitBg,
                        radius: 10,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(stats.overallCompletionRate * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'TOTAL',
                        style: TextStyle(color: Colors.grey, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statRow(
                  'TOTAL',
                  stats.totalChallenges.toString(),
                  Colors.white,
                ),
                const SizedBox(height: 12),
                _statRow(
                  'COMPLETED',
                  stats.completedChallenges.toString(),
                  AppColors.habitPrimary,
                ),
                const SizedBox(height: 12),
                _statRow(
                  'ONGOING',
                  stats.ongoingChallenges.toString(),
                  Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart(Map<DateTime, int> history) {
    final sortedDates = history.keys.toList()..sort();
    final dataPoints = sortedDates.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), history[e.value]!.toDouble());
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              color: AppColors.habitPrimary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.habitPrimary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyInsight(ChallengeIntelStats stats) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = today.subtract(Duration(days: 6 - index));
        final completedCount = stats.completionHistory[date] ?? 0;
        final isCompleted = completedCount > 0;

        return Column(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.habitPrimary.withOpacity(0.1)
                    : AppColors.highPriorityColor.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.habitPrimary
                      : AppColors.highPriorityColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.close,
                size: 16,
                color: isCompleted
                    ? AppColors.habitPrimary
                    : AppColors.highPriorityColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('E').format(date)[0],
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _HabitsView extends HookConsumerWidget {
  const _HabitsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(habitStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('HABIT COMPLETION OVERVIEW'),
          // const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'TOTAL',
                  stats.totalHabits.toString(),
                  Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'DONE TODAY',
                  stats.completedToday.toString(),
                  AppColors.habitPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'MISSED',
                  stats.missedToday.toString(),
                  AppColors.highPriorityColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _sectionHeader('DAILY HABIT TREND'),
          const SizedBox(height: 20),
          _buildWeeklyBarChart(stats.weeklyTrend),
          const SizedBox(height: 40),
          _sectionHeader('HABIT-WISE PROGRESS'),
          const SizedBox(height: 20),
          ...stats.habitDetails.map((h) => _buildHabitProgress(h)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(Map<DateTime, int> weeklyTrend) {
    final sortedDates = weeklyTrend.keys.toList()..sort();
    final barGroups = sortedDates.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: weeklyTrend[e.value]!.toDouble(),
            color: AppColors.habitPrimary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = sortedDates[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(date)[0],
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildHabitProgress(HabitDetailStats detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SUCCESS RATE: ${(detail.completionRate * 100).toInt()}%',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${detail.currentStreak}',
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'STREAK',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _sectionHeader(String title) {
  return Text(
    title,
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
    ),
  );
}

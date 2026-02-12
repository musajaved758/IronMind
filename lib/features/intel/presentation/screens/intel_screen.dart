import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/intel/presentation/providers/stats_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class IntelScreen extends HookConsumerWidget {
  const IntelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PROGRESS',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildToggle(currentPage, pageController, colors),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (index) => currentPage.value = index,
                children: const [_ChallengesView(), _HabitsView()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(
    ValueNotifier<int> currentPage,
    PageController pageController,
    AppColorScheme colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: _toggleItem(
                'CHALLENGES',
                currentPage.value == 0,
                () => pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                colors,
              ),
            ),
            Expanded(
              child: _toggleItem(
                'HABITS',
                currentPage.value == 1,
                () => pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                colors,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(
    String label,
    bool isSelected,
    VoidCallback onTap,
    AppColorScheme colors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colors.textMuted,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHALLENGES TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ChallengesView extends HookConsumerWidget {
  const _ChallengesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(challengeStatsProvider);
    final colors = Theme.of(context).appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('OVERALL CHALLENGE PROGRESS', colors),
          const SizedBox(height: 20),
          _buildRadialProgress(stats, colors),
          const SizedBox(height: 20),
          _buildStreakCards(
            stats.bestCurrentStreak,
            stats.bestLongestStreak,
            colors,
          ),
          const SizedBox(height: 40),
          _sectionHeader('STREAK & CONSISTENCY', colors),
          const SizedBox(height: 20),
          _ConsistencyCalendar(
            monthlyProgress: stats.monthlyProgress,
            computeDayCount: (date) {
              int count = 0;
              for (final c in stats.allChallenges) {
                if (c.isCompletedOn(date)) count++;
              }
              return count;
            },
            colors: colors,
          ),
          const SizedBox(height: 40),
          _sectionHeader('PROGRESS OVER TIME', colors),
          const SizedBox(height: 20),
          _buildProgressChart(stats.completionHistory, colors),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildRadialProgress(
    ChallengeIntelStats stats,
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: SfCircularChart(
              margin: EdgeInsets.zero,
              annotations: <CircularChartAnnotation>[
                CircularChartAnnotation(
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(stats.overallCompletionRate * 100).toInt()}%',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'TOTAL',
                        style: TextStyle(color: colors.textMuted, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
              series: <CircularSeries>[
                DoughnutSeries<_PieData, String>(
                  dataSource: [
                    _PieData(
                      'Completed',
                      stats.overallCompletionRate * 100,
                      colors.primary,
                    ),
                    _PieData(
                      'Remaining',
                      (1 - stats.overallCompletionRate) * 100,
                      colors.progressBarBg,
                    ),
                  ],
                  xValueMapper: (_PieData d, _) => d.label,
                  yValueMapper: (_PieData d, _) => d.value,
                  pointColorMapper: (_PieData d, _) => d.color,
                  innerRadius: '75%',
                  radius: '100%',
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
                  colors.textPrimary,
                  colors,
                ),
                const SizedBox(height: 12),
                _statRow(
                  'COMPLETED',
                  stats.completedChallenges.toString(),
                  colors.primary,
                  colors,
                ),
                const SizedBox(height: 12),
                _statRow(
                  'ONGOING',
                  stats.ongoingChallenges.toString(),
                  colors.accent,
                  colors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(
    String label,
    String value,
    Color valueColor,
    AppColorScheme colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textMuted,
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

  Widget _buildProgressChart(
    Map<DateTime, int> history,
    AppColorScheme colors,
  ) {
    final sortedDates = history.keys.toList()..sort();
    final dataPoints = sortedDates
        .map((date) => _TimeData(date, history[date]!.toDouble()))
        .toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: DateTimeAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: AxisLine(color: colors.border),
          labelStyle: TextStyle(color: colors.textMuted, fontSize: 9),
          dateFormat: DateFormat.Md(),
          intervalType: DateTimeIntervalType.days,
          interval: 7,
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(
            color: colors.border.withOpacity(0.3),
            dashArray: const [4, 4],
          ),
          axisLine: const AxisLine(width: 0),
          labelStyle: TextStyle(color: colors.textMuted, fontSize: 10),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          SplineAreaSeries<_TimeData, DateTime>(
            dataSource: dataPoints,
            xValueMapper: (_TimeData d, _) => d.date,
            yValueMapper: (_TimeData d, _) => d.value,
            color: colors.primary,
            borderColor: colors.primary,
            borderWidth: 3,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primary.withOpacity(0.3),
                colors.primary.withOpacity(0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HABITS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _HabitsView extends HookConsumerWidget {
  const _HabitsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(habitStatsProvider);
    final colors = Theme.of(context).appColors;

    // Build monthly progress for habits (same structure as challenges)
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final Map<DateTime, int> habitMonthlyProgress = {};
    for (int i = 0; i < daysInMonth; i++) {
      final date = startOfMonth.add(Duration(days: i));
      int count = 0;
      for (final h in stats.allHabits) {
        if (h.isCompletedOn(date)) count++;
      }
      habitMonthlyProgress[date] = count;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('HABIT COMPLETION OVERVIEW', colors),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'TOTAL',
                  stats.totalHabits.toString(),
                  colors.accent,
                  colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'DONE TODAY',
                  stats.completedToday.toString(),
                  colors.primary,
                  colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'MISSED',
                  stats.missedToday.toString(),
                  AppColors.highPriorityColor,
                  colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStreakCards(
            stats.bestCurrentStreak,
            stats.bestLongestStreak,
            colors,
          ),
          const SizedBox(height: 40),
          _sectionHeader('STREAK & CONSISTENCY', colors),
          const SizedBox(height: 20),
          _ConsistencyCalendar(
            monthlyProgress: habitMonthlyProgress,
            computeDayCount: (date) {
              int count = 0;
              for (final h in stats.allHabits) {
                if (h.isCompletedOn(date)) count++;
              }
              return count;
            },
            colors: colors,
          ),
          const SizedBox(height: 40),
          _sectionHeader('DAILY HABIT TREND', colors),
          const SizedBox(height: 20),
          _buildWeeklyBarChart(stats.weeklyTrend, colors),
          const SizedBox(height: 40),
          _sectionHeader('HABIT-WISE PROGRESS', colors),
          const SizedBox(height: 20),
          ...stats.habitDetails.map((h) => _buildHabitProgress(h, colors)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _miniStat(
    String label,
    String value,
    Color color,
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colors.surface,
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
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(
    Map<DateTime, int> weeklyTrend,
    AppColorScheme colors,
  ) {
    final sortedDates = weeklyTrend.keys.toList()..sort();
    final dataPoints = sortedDates
        .map(
          (date) => _BarData(
            DateFormat('E').format(date)[0],
            weeklyTrend[date]!.toDouble(),
          ),
        )
        .toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: AxisLine(color: colors.border),
          labelStyle: TextStyle(color: colors.textMuted, fontSize: 10),
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(
            color: colors.border.withOpacity(0.3),
            dashArray: const [4, 4],
          ),
          axisLine: const AxisLine(width: 0),
          labelStyle: TextStyle(color: colors.textMuted, fontSize: 10),
        ),
        series: <CartesianSeries>[
          ColumnSeries<_BarData, String>(
            dataSource: dataPoints,
            xValueMapper: (_BarData d, _) => d.label,
            yValueMapper: (_BarData d, _) => d.value,
            color: colors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            width: 0.5,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitProgress(HabitDetailStats detail, AppColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
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
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SUCCESS RATE: ${(detail.completionRate * 100).toInt()}%',
                  style: TextStyle(color: colors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
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
                    'CURRENT',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    '${detail.bestStreak}',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'BEST',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Streak cards showing current and longest streak (shared by both tabs)
Widget _buildStreakCards(
  int currentStreak,
  int longestStreak,
  AppColorScheme colors,
) {
  return Row(
    children: [
      Expanded(
        child: _streakCard(
          'CURRENT STREAK',
          '$currentStreak',
          'Days',
          Colors.orangeAccent,
          colors,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _streakCard(
          'LONGEST STREAK',
          '$longestStreak',
          'Days',
          colors.primary,
          colors,
        ),
      ),
    ],
  );
}

Widget _streakCard(
  String label,
  String value,
  String unit,
  Color accentColor,
  AppColorScheme colors,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accentColor.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: accentColor,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                unit,
                style: TextStyle(
                  color: accentColor.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}

Widget _sectionHeader(String title, AppColorScheme colors) {
  return Text(
    title,
    style: TextStyle(
      color: colors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CONSISTENCY CALENDAR (Month / 90 Days / Year dropdown)
// ─────────────────────────────────────────────────────────────────────────────

class _ConsistencyCalendar extends HookWidget {
  final Map<DateTime, int> monthlyProgress;
  final int Function(DateTime date) computeDayCount;
  final AppColorScheme colors;

  const _ConsistencyCalendar({
    required this.monthlyProgress,
    required this.computeDayCount,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final viewMode = useState('Month');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTitle(viewMode.value),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.chipBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border.withOpacity(0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: viewMode.value,
                    isDense: true,
                    dropdownColor: colors.dialogBg,
                    borderRadius: BorderRadius.circular(12),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    icon: Icon(
                      Icons.expand_more,
                      color: colors.textSecondary,
                      size: 18,
                    ),
                    items: ['Month', '90 Days', 'Year'].map((m) {
                      return DropdownMenuItem(value: m, child: Text(m));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) viewMode.value = val;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (viewMode.value == 'Month')
            _buildMonthView()
          else
            _HeatmapGrid(
              key: ValueKey(viewMode.value),
              mode: viewMode.value,
              computeDayCount: computeDayCount,
              colors: colors,
            ),
        ],
      ),
    );
  }

  String _getTitle(String mode) {
    final now = DateTime.now();
    switch (mode) {
      case 'Month':
        return DateFormat('MMMM yyyy').format(now).toUpperCase();
      case '90 Days':
        return 'LAST 90 DAYS';
      case 'Year':
        return '${now.year} OVERVIEW';
      default:
        return '';
    }
  }

  Widget _buildMonthView() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final startingWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: daysInMonth + (startingWeekday - 1),
          itemBuilder: (context, index) {
            if (index < startingWeekday - 1) {
              return const SizedBox();
            }
            final day = index - (startingWeekday - 1) + 1;
            final date = DateTime(now.year, now.month, day);
            final count = monthlyProgress[date] ?? 0;
            final isToday =
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
            final isFuture = date.isAfter(now);

            Color bgColor = colors.progressBarBg;
            Color textColor = colors.textMuted;

            if (!isFuture) {
              if (count > 0) {
                bgColor = colors.primary;
                textColor = Colors.white;
              } else if (date.isBefore(
                DateTime(now.year, now.month, now.day),
              )) {
                bgColor = AppColors.highPriorityColor.withOpacity(0.2);
                textColor = AppColors.highPriorityColor;
              }
            }

            if (isToday && count == 0) {
              bgColor = colors.primary.withOpacity(0.2);
              textColor = colors.primary;
            }

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(color: colors.primary, width: 1)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GITHUB-STYLE HEATMAP GRID (auto-scrolls to current week)
// ─────────────────────────────────────────────────────────────────────────────

class _HeatmapGrid extends StatefulWidget {
  final String mode;
  final int Function(DateTime date) computeDayCount;
  final AppColorScheme colors;

  const _HeatmapGrid({
    super.key,
    required this.mode,
    required this.computeDayCount,
    required this.colors,
  });

  @override
  State<_HeatmapGrid> createState() => _HeatmapGridState();
}

class _HeatmapGridState extends State<_HeatmapGrid> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final mode = widget.mode;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final int totalDays = mode == '90 Days' ? 90 : 365;
    final rawStart = today.subtract(Duration(days: totalDays - 1));

    // Align start to Monday of that week
    final adjustedStart = rawStart.subtract(
      Duration(days: rawStart.weekday - 1),
    );

    // Compute completion data
    final Map<DateTime, int> progress = {};
    for (int i = 0; i < totalDays; i++) {
      final date = rawStart.add(Duration(days: i));
      progress[date] = widget.computeDayCount(date);
    }

    final double cellSize = mode == '90 Days' ? 22 : 12;
    final double spacing = mode == '90 Days' ? 3 : 2;
    final totalAdjustedDays = today.difference(adjustedStart).inDays + 1;
    final int weeksCount = (totalAdjustedDays / 7).ceil();

    // Build month labels at week positions
    final List<_MonthLabel> monthLabels = [];
    String? lastMonth;
    for (int w = 0; w < weeksCount; w++) {
      final weekMonday = adjustedStart.add(Duration(days: w * 7));
      final monthKey = '${weekMonday.year}-${weekMonday.month}';
      if (monthKey != lastMonth) {
        monthLabels.add(_MonthLabel(DateFormat('MMM').format(weekMonday), w));
        lastMonth = monthKey;
      }
    }

    final dayLabels = ['Mon', '', 'Wed', '', 'Fri', '', ''];
    const double dayLabelWidth = 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Y-axis: day-of-week labels
            SizedBox(
              width: dayLabelWidth,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ...List.generate(7, (i) {
                    return SizedBox(
                      height: cellSize + spacing,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          dayLabels[i],
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: mode == '90 Days' ? 10 : 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Scrollable heatmap grid
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // X-axis: month labels
                    SizedBox(
                      height: 16,
                      width: weeksCount * (cellSize + spacing),
                      child: Stack(
                        children: monthLabels.map((ml) {
                          return Positioned(
                            left: ml.weekIndex * (cellSize + spacing),
                            child: Text(
                              ml.label,
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: mode == '90 Days' ? 10 : 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Grid cells
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(weeksCount, (weekIndex) {
                        return SizedBox(
                          width: cellSize + spacing,
                          child: Column(
                            children: List.generate(7, (dayIndex) {
                              final date = adjustedStart.add(
                                Duration(days: weekIndex * 7 + dayIndex),
                              );
                              final isInRange =
                                  !date.isBefore(rawStart) &&
                                  !date.isAfter(today);

                              if (!isInRange) {
                                return SizedBox(
                                  height: cellSize + spacing,
                                  width: cellSize,
                                );
                              }

                              final count = progress[date] ?? 0;

                              Color bgColor;
                              if (count == 0) {
                                bgColor = colors.progressBarBg;
                              } else if (count == 1) {
                                bgColor = colors.primary.withOpacity(0.35);
                              } else if (count == 2) {
                                bgColor = colors.primary.withOpacity(0.6);
                              } else {
                                bgColor = colors.primary;
                              }

                              return Padding(
                                padding: EdgeInsets.all(spacing / 2),
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(
                                      mode == '90 Days' ? 4 : 2,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Less ',
              style: TextStyle(color: colors.textMuted, fontSize: 10),
            ),
            ...List.generate(4, (i) {
              final opacity = [0.15, 0.35, 0.6, 1.0][i];
              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(opacity),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
            Text(
              ' More',
              style: TextStyle(color: colors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA CLASSES
// ─────────────────────────────────────────────────────────────────────────────

class _PieData {
  final String label;
  final double value;
  final Color color;
  _PieData(this.label, this.value, this.color);
}

class _TimeData {
  final DateTime date;
  final double value;
  _TimeData(this.date, this.value);
}

class _BarData {
  final String label;
  final double value;
  _BarData(this.label, this.value);
}

class _MonthLabel {
  final String label;
  final int weekIndex;
  _MonthLabel(this.label, this.weekIndex);
}

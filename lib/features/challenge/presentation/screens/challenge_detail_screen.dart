import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/challenge/data/models/challenge_model.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChallengeDetailScreen extends HookConsumerWidget {
  final ChallengeModel challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allChallenges = ref.watch(challengeProvider);
    final freshChallenge = allChallenges.firstWhere(
      (c) => c.id == challenge.id,
      orElse: () => challenge,
    );
    final colors = Theme.of(context).appColors;
    final isCompleted = freshChallenge.isCompleted;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isCompleted ? 'MISSION ARCHIVE' : freshChallenge.name.toUpperCase(),
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!isCompleted)
            IconButton(
              icon: Icon(Icons.edit, color: colors.textPrimary),
              onPressed: () {
                // Navigate to edit screen if we had one here, but currently
                // it seems edit is handled in ChallengeScreen via PopupMenu.
                // However, the user said "After clicking on the completed challenge
                // the detail screen should be opening but enable to edit."
                // So I will just make sure no edit button appears here.
              },
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (isCompleted) _buildCompletionBanner(colors),
              _buildOverviewCard(freshChallenge, colors),
              const SizedBox(height: 20),
              // Only allow mission log interaction if not completed
              IgnorePointer(
                ignoring: isCompleted,
                child: Opacity(
                  opacity: isCompleted ? 0.8 : 1.0,
                  child: _ChallengeCalendar(
                    challenge: freshChallenge,
                    colors: colors,
                    ref: ref,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isCompleted) ...[
                _buildActionCard(context, ref, freshChallenge, colors),
                const SizedBox(height: 20),
              ],
              _buildCompletionChart(freshChallenge, colors),
              const SizedBox(height: 20),
              _buildMilestonesList(freshChallenge, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(ChallengeModel challenge, AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoColumn(
                'CURRENT\nSTREAK',
                '${challenge.currentStreak} Days',
                colors,
              ),
              _infoColumn(
                'LONGEST\nSTREAK',
                '${challenge.longestStreak} Days',
                colors,
              ),
              _infoColumn(
                'REMAINING',
                '${challenge.daysRemaining} Days',
                colors,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: challenge.progress,
              minHeight: 10,
              backgroundColor: colors.progressBarBg,
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(challenge.progress * 100).toInt()}% COMPLETED',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value, AppColorScheme colors) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionChart(
    ChallengeModel challenge,
    AppColorScheme colors,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<_ChartData> data = [];

    for (int i = 3; i >= 0; i--) {
      final weekStart = today.subtract(
        Duration(days: today.weekday - 1 + (i * 7)),
      );
      int completedInWeek = 0;
      int totalInWeek = 0;

      for (int d = 0; d < 7; d++) {
        final date = weekStart.add(Duration(days: d));
        if (date.isAfter(today)) continue;

        final startDate = DateTime(
          challenge.startDate.year,
          challenge.startDate.month,
          challenge.startDate.day,
        );
        final endDate = startDate.add(Duration(days: challenge.duration));

        if ((date.isAtSameMomentAs(startDate) || date.isAfter(startDate)) &&
            date.isBefore(endDate)) {
          totalInWeek++;
          if (challenge.isCompletedOn(date)) completedInWeek++;
        }
      }

      final weekLabel = 'W${4 - i}';
      data.add(_ChartData(weekLabel, completedInWeek, totalInWeek));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY COMPLETION',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: AxisLine(color: colors.border),
                labelStyle: TextStyle(
                  color: colors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
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
              series: <CartesianSeries<_ChartData, String>>[
                ColumnSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (_ChartData d, _) => d.week,
                  yValueMapper: (_ChartData d, _) => d.completed,
                  name: 'Completed',
                  color: colors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  width: 0.5,
                ),
                ColumnSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (_ChartData d, _) => d.week,
                  yValueMapper: (_ChartData d, _) => d.total,
                  name: 'Total',
                  color: colors.progressBarBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  width: 0.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesList(ChallengeModel challenge, AppColorScheme colors) {
    if (challenge.roadmap.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MILESTONES',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...challenge.roadmap.map(
            (milestone) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.flag, color: colors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          milestone.title,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (milestone.subtasks.isNotEmpty)
                          Text(
                            '${milestone.subtasks.length} subtasks',
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBanner(AppColorScheme colors) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withOpacity(0.2),
            colors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, color: colors.primary, size: 48),
          const SizedBox(height: 12),
          Text(
            'MISSION ACCOMPLISHED',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A true brother knows no limits.',
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STRATEGIC OPTIONS',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  'EXTEND MISSION',
                  Icons.add_circle_outline,
                  colors.primary,
                  () => _showExtendDialog(context, ref, challenge, colors),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  'DELETE ARCHIVE',
                  Icons.delete_outline,
                  AppColors.highPriorityColor,
                  () => _showDeleteDialog(context, ref, challenge, colors),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExtendDialog(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
    AppColorScheme colors,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.dialogBg,
        title: Text(
          'EXTEND MISSION',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How many more days will you commit to?',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _durationOption(context, ref, challenge, 7, colors),
                _durationOption(context, ref, challenge, 14, colors),
                _durationOption(context, ref, challenge, 30, colors),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationOption(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
    int days,
    AppColorScheme colors,
  ) {
    return InkWell(
      onTap: () {
        ref
            .read(challengeProvider.notifier)
            .extendChallenge(challenge.id, days);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mission extended by $days days!'),
            backgroundColor: colors.primary,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.chipBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+$days',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
    AppColorScheme colors,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.dialogBg,
        title: Text(
          'PURGE ARCHIVE?',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently remove all records of this mission.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('KEEP IT', style: TextStyle(color: colors.primary)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(challengeProvider.notifier)
                  .deleteChallenge(challenge.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            child: const Text(
              'PURGE',
              style: TextStyle(color: AppColors.highPriorityColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pageable monthly calendar for challenge tracking
class _ChallengeCalendar extends StatefulWidget {
  final ChallengeModel challenge;
  final AppColorScheme colors;
  final WidgetRef ref;

  const _ChallengeCalendar({
    required this.challenge,
    required this.colors,
    required this.ref,
  });

  @override
  State<_ChallengeCalendar> createState() => _ChallengeCalendarState();
}

class _ChallengeCalendarState extends State<_ChallengeCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final challenge = widget.challenge;

    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final firstWeekday = _displayedMonth.weekday;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final challengeStart = DateTime(
      challenge.startDate.year,
      challenge.startDate.month,
      challenge.startDate.day,
    );
    final challengeEnd = challengeStart.add(Duration(days: challenge.duration));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MISSION LOG',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                children: [
                  _navButton(Icons.chevron_left, _previousMonth, colors),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      DateFormat(
                        'MMM yyyy',
                      ).format(_displayedMonth).toUpperCase(),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _navButton(Icons.chevron_right, _nextMonth, colors),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemCount: daysInMonth + firstWeekday - 1,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox();
              }
              final day = index - (firstWeekday - 1) + 1;
              final date = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                day,
              );
              final isCompleted = challenge.isCompletedOn(date);
              final isToday =
                  date.year == todayDate.year &&
                  date.month == todayDate.month &&
                  date.day == todayDate.day;
              final isPast = date.isBefore(todayDate) && !isToday;
              final isFuture = date.isAfter(todayDate) && !isToday;

              final inRange =
                  (date.isAtSameMomentAs(challengeStart) ||
                      date.isAfter(challengeStart)) &&
                  date.isBefore(challengeEnd);

              Color bgColor = colors.chipBg;
              Color textColor = colors.textMuted;
              Border? border;

              if (!inRange) {
                bgColor = colors.chipBg.withOpacity(0.3);
                textColor = colors.textMuted.withOpacity(0.3);
              } else if (isCompleted) {
                bgColor = colors.primary;
                textColor = Colors.white;
              } else if (isPast && !isCompleted) {
                bgColor = AppColors.highPriorityColor.withOpacity(0.15);
                textColor = AppColors.highPriorityColor.withOpacity(0.7);
              } else if (isToday) {
                border = Border.all(color: colors.primary, width: 1.5);
                textColor = colors.textPrimary;
              } else if (isFuture) {
                bgColor = colors.chipBg.withOpacity(0.5);
                textColor = colors.textMuted.withOpacity(0.4);
              }

              return InkWell(
                onTap: (isFuture || !inRange)
                    ? null
                    : () {
                        widget.ref
                            .read(challengeProvider.notifier)
                            .toggleCompletion(challenge.id, date);
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: border,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap, AppColorScheme colors) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.chipBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colors.textSecondary, size: 18),
      ),
    );
  }
}

class _ChartData {
  final String week;
  final int completed;
  final int total;

  _ChartData(this.week, this.completed, this.total);
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/home/presentation/widgets/daily_summary_card.dart';
import 'package:iron_mind/features/home/presentation/widgets/habit_list_view.dart';
import 'package:iron_mind/core/providers/app_providers.dart';
import 'package:iron_mind/features/habit/presentation/providers/habit_provider.dart';
import 'package:iron_mind/features/habit/data/models/habit_model.dart';

import 'package:iron_mind/features/habit/presentation/screens/create_habit_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final habits = ref.watch(habitProvider);
    final colors = Theme.of(context).appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showCalendar = ref.watch(showHabitCalendarProvider);

    // Start collapsed (showing only week view)
    final scrollController = ScrollController(
      initialScrollOffset: showCalendar ? 260 : 0,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colors.bg,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
            bottom: 80,
          ), // Avoid overlap with NavBar
          child: FloatingActionButton(
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateHabitScreen(),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              if (showCalendar)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CalendarHeaderDelegate(
                    selectedDate: selectedDate,
                    habits: habits,
                    onDateSelected: (date) {
                      ref.read(selectedDateProvider.notifier).state = date;
                    },
                    onTodayPressed: () {
                      ref.read(selectedDateProvider.notifier).state =
                          DateTime.now();
                    },
                    colors: colors,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d').format(selectedDate),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                ref
                                    .read(selectedDateProvider.notifier)
                                    .state = selectedDate.subtract(
                                  const Duration(days: 1),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.chevron_left,
                                  color: colors.textSecondary,
                                  size: 22,
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                ref.read(selectedDateProvider.notifier).state =
                                    DateTime.now();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'TODAY',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                ref.read(selectedDateProvider.notifier).state =
                                    selectedDate.add(const Duration(days: 1));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: colors.textSecondary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                sliver: SliverToBoxAdapter(
                  child: DailySummaryCard(selectedDate: selectedDate),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: HabitListView(selectedDate: selectedDate),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DateTime selectedDate;
  final List<HabitModel> habits;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onTodayPressed;
  final AppColorScheme colors;

  _CalendarHeaderDelegate({
    required this.selectedDate,
    required this.habits,
    required this.onDateSelected,
    required this.onTodayPressed,
    required this.colors,
  });

  @override
  double get minExtent => 110.0;
  @override
  double get maxExtent => 400.0;

  /// Get the completion ratio for a date (0.0 to 1.0)
  double _getCompletionRatio(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final activeHabits = habits.where((habit) {
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
          (dateOnly.isAtSameMomentAs(startDate) ||
              dateOnly.isAfter(startDate)) &&
          (dateOnly.isAtSameMomentAs(endDate) || dateOnly.isBefore(endDate));

      if (!isInRange) return false;

      if (habit.frequency == 'WEEKLY') {
        return dateOnly.weekday == DateTime.saturday ||
            dateOnly.weekday == DateTime.sunday;
      }
      return true;
    }).toList();

    if (activeHabits.isEmpty) return -1.0; // No habits for this day

    final completed = activeHabits.where((h) => h.isCompletedOn(date)).length;
    return completed / activeHabits.length;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final isToday =
        DateTime.now().day == selectedDate.day &&
        DateTime.now().month == selectedDate.month &&
        DateTime.now().year == selectedDate.year;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        boxShadow: progress > 0.8
            ? [
                BoxShadow(
                  color: colors.border.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // ── Header Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onTodayPressed,
                  child: Row(
                    children: [
                      Text(
                        DateFormat(
                          'MMMM yyyy',
                        ).format(selectedDate).toUpperCase(),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (!isToday) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "TODAY",
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (progress < 0.5)
                  Row(
                    children: [
                      _headerIconButton(
                        Icons.chevron_left,
                        () => onDateSelected(
                          DateTime(
                            selectedDate.year,
                            selectedDate.month - 1,
                            1,
                          ),
                        ),
                      ),
                      _headerIconButton(
                        Icons.chevron_right,
                        () => onDateSelected(
                          DateTime(
                            selectedDate.year,
                            selectedDate.month + 1,
                            1,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Calendar Body ──
          Expanded(
            child: progress > 0.8
                ? _WeekStrip(
                    selectedDate: selectedDate,
                    onDateSelected: onDateSelected,
                    getCompletionRatio: _getCompletionRatio,
                    colors: colors,
                  )
                : Opacity(
                    opacity: (1.0 - progress).clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: progress > 0.5,
                      child: _MonthCalendar(
                        selectedDate: selectedDate,
                        onDateSelected: onDateSelected,
                        getCompletionRatio: _getCompletionRatio,
                        colors: colors,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: colors.textSecondary, size: 22),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CalendarHeaderDelegate oldDelegate) {
    return oldDelegate.selectedDate != selectedDate ||
        oldDelegate.colors != colors ||
        oldDelegate.habits != habits;
  }
}

// ── Rounded-box Week Strip (collapsed view) ──
class _WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final double Function(DateTime) getCompletionRatio;
  final AppColorScheme colors;

  const _WeekStrip({
    required this.selectedDate,
    required this.onDateSelected,
    required this.getCompletionRatio,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // Get the week containing selectedDate (Mon-Sun)
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          return Expanded(
            child: _DayCard(
              date: date,
              selectedDate: selectedDate,
              onTap: () => onDateSelected(date),
              completionRatio: getCompletionRatio(date),
              colors: colors,
              compact: true,
            ),
          );
        }),
      ),
    );
  }
}

// ── Full Month Calendar (expanded view) ──
class _MonthCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final double Function(DateTime) getCompletionRatio;
  final AppColorScheme colors;

  const _MonthCalendar({
    required this.selectedDate,
    required this.onDateSelected,
    required this.getCompletionRatio,
    required this.colors,
  });
  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      selectedDate.year,
      selectedDate.month,
    );
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Column(
      children: [
        // Day-of-week headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Day grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
                mainAxisSpacing: 6,
                crossAxisSpacing: 4,
              ),
              itemCount: daysInMonth + firstWeekday - 1,
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) {
                  return const SizedBox();
                }
                final day = index - (firstWeekday - 1) + 1;
                final date = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  day,
                );
                return _DayCard(
                  date: date,
                  selectedDate: selectedDate,
                  onTap: () => onDateSelected(date),
                  completionRatio: getCompletionRatio(date),
                  colors: colors,
                  compact: false,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Individual Day Card (rounded box with heatmap) ──
class _DayCard extends StatelessWidget {
  final DateTime date;
  final DateTime selectedDate;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final bool compact;

  /// -1.0 = no habits for this day, 0.0 = no completion, 1.0 = all done
  final double completionRatio;

  const _DayCard({
    required this.date,
    required this.selectedDate,
    required this.onTap,
    required this.colors,
    required this.compact,
    required this.completionRatio,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year;
    final now = DateTime.now();
    final isToday =
        date.day == now.day && date.month == now.month && date.year == now.year;

    // Don't show heatmap for future dates
    final isFuture = DateTime(
      date.year,
      date.month,
      date.day,
    ).isAfter(DateTime(now.year, now.month, now.day));

    // Colors
    Color bgColor;
    Color textColor;
    Color dayNameColor;

    if (isSelected) {
      bgColor = colors.calendarSelectedBg;
      textColor = colors.calendarSelectedText;
      dayNameColor = colors.calendarSelectedText.withOpacity(0.8);
    } else if (isToday) {
      bgColor = colors.primary.withOpacity(0.12);
      textColor = colors.primary;
      dayNameColor = colors.primary.withOpacity(0.7);
    } else {
      bgColor = colors.calendarDayBg;
      textColor = colors.calendarDayText;
      dayNameColor = colors.textMuted;
    }

    final dayName = DateFormat('E').format(date).toUpperCase().substring(0, 3);

    // Heatmap dot color (GitHub-style intensity)
    final bool showDot = !isFuture && completionRatio >= 0;
    Color? dotColor;
    if (showDot && completionRatio > 0) {
      // 4 intensity levels like GitHub
      if (completionRatio >= 1.0) {
        dotColor = colors.primary; // Full intensity
      } else if (completionRatio >= 0.66) {
        dotColor = colors.primary.withOpacity(0.7);
      } else if (completionRatio >= 0.33) {
        dotColor = colors.primary.withOpacity(0.45);
      } else {
        dotColor = colors.primary.withOpacity(0.25);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: compact ? 2 : 2,
          vertical: compact ? 2 : 2,
        ),
        padding: EdgeInsets.symmetric(vertical: compact ? 4 : 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(compact ? 12 : 14),
          border: isToday && !isSelected
              ? Border.all(color: colors.calendarTodayBorder, width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: dayNameColor,
                fontSize: compact ? 9 : 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: compact ? 2 : 2),
            Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontSize: compact ? 14 : 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            // Heatmap indicator dot
            if (showDot) ...[
              const SizedBox(height: 3),
              completionRatio >= 1.0
                  ? Icon(
                      Icons.check_circle,
                      size: 10,
                      color: isSelected
                          ? colors.calendarSelectedText
                          : colors.primary,
                    )
                  : Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor ?? colors.textMuted.withOpacity(0.25),
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}

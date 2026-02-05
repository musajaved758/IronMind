import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/features/habit/presentation/providers/habit_provider.dart';

class TimeLineWidget extends HookConsumerWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateChange;

  const TimeLineWidget({
    super.key,
    required this.onDateChange,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);

    bool isDayFullyCompleted(DateTime date) {
      if (habits.isEmpty) return false;
      return habits.every((h) => h.isCompletedOn(date));
    }

    return EasyDateTimeLine(
      initialDate: selectedDate,
      onDateChange: onDateChange,
      headerProps: const EasyHeaderProps(
        monthPickerType: MonthPickerType.switcher,
        dateFormatter: DateFormatter.fullDateDMY(),
      ),
      activeColor: AppColors.glowingGreen,
      dayProps: const EasyDayProps(
        dayStructure: DayStructure.dayStrDayNum,
        height: 80,
        width: 60,
        borderColor: AppColors.border,
        activeDayStyle: DayStyle(
          decoration: BoxDecoration(
            color: AppColors.glowingGreen,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
        ),
        inactiveDayStyle: DayStyle(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
        ),
      ),
      itemBuilder: (context, date, isSelected, onTap) {
        final isCompleted = isDayFullyCompleted(date);

        Color bgColor = isSelected
            ? AppColors.glowingGreen
            : AppColors.cardBackground;
        Color textColor = isSelected
            ? AppColors.primary
            : AppColors.textPrimaryWhite;
        BorderSide border = const BorderSide(color: AppColors.border);

        if (isCompleted && !isSelected) {
          bgColor = Colors.green.shade800;
        }

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.fromBorderSide(border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  EasyDateFormatter.shortDayName(date, "en_US"),
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCompleted)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

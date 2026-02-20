import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/home/presentation/widgets/daily_summary_card.dart';
import 'package:iron_mind/core/providers/app_providers.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final colors = Theme.of(context).appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
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
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

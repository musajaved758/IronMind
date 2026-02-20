import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/core/providers/app_providers.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:iron_mind/features/challenge/data/models/challenge_model.dart';
import 'package:iron_mind/features/challenge/presentation/screens/challenge_detail_screen.dart';
import 'package:iron_mind/features/intel/presentation/providers/stats_provider.dart';

import 'package:iron_mind/features/challenge/presentation/screens/create_challenge_screen.dart';

class ChallengeScreen extends HookConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allChallenges = ref.watch(challengeProvider);
    final maxChallenges = ref.watch(maxChallengesProvider);
    final stats = ref.watch(challengeStatsProvider);
    final colors = Theme.of(context).appColors;

    // Use same ongoing/completed logic as stats provider
    final ongoing = stats.activeChallenges;
    final completed = allChallenges.where((c) {
      final endDate = c.startDate.add(Duration(days: c.duration));
      final now = DateTime.now();
      return endDate.isBefore(now) || endDate.isAtSameMomentAs(now);
    }).toList();

    // Only show up to maxChallenges ongoing challenges
    final visibleOngoing = ongoing.take(maxChallenges).toList();

    return Scaffold(
      backgroundColor: colors.bg,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Avoid overlap with NavBar
        child: FloatingActionButton(
          backgroundColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
          onPressed: () {
            if (ongoing.length >= maxChallenges) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'You have reached the max of $maxChallenges active challenges',
                  ),
                  backgroundColor: AppColors.highPriorityColor,
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateChallengeScreen(),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MISSIONS',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: allChallenges.isEmpty
            ? _buildEmptyState(colors)
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),
                        if (visibleOngoing.isNotEmpty) ...[
                          _sectionHeader(
                            'ACTIVE MISSIONS (${visibleOngoing.length})',
                            colors,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ]),
                    ),
                  ),
                  if (visibleOngoing.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverReorderableList(
                        itemCount: visibleOngoing.length,
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(challengeProvider.notifier)
                              .reorderChallenges(
                                oldIndex,
                                newIndex,
                                visibleOngoing.map((c) => c.id).toList(),
                              );
                        },
                        itemBuilder: (context, index) {
                          final c = visibleOngoing[index];
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(c.id),
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildChallengeCard(
                                context,
                                ref,
                                c,
                                colors,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (visibleOngoing.isEmpty && completed.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Center(
                              child: Text(
                                'All missions completed!',
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (completed.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _sectionHeader(
                            'COMPLETED (${completed.length})',
                            colors,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ]),
                    ),
                  ),
                  if (completed.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final c = completed[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCompletedCard(context, c, colors),
                          );
                        }, childCount: completed.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
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

  Widget _buildEmptyState(AppColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.military_tech,
            size: 64,
            color: colors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'NO ACTIVE MISSIONS',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
    AppColorScheme colors,
  ) {
    final today = DateTime.now();
    final isTodayCompleted = challenge.isCompletedOn(today);

    Color threatColor = challenge.threatLevel == 'HARD'
        ? AppColors.highPriorityColor
        : (challenge.threatLevel == 'MEDIUM'
              ? AppColors.mediumPriorityColor
              : AppColors.lowPriorityColor);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChallengeDetailScreen(challenge: challenge),
                  ),
                );
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _statusBadge(
                                    challenge.threatLevel,
                                    threatColor,
                                  ),
                                  const SizedBox(width: 8),
                                  _statusBadge(
                                    'DAY ${challenge.daysElapsed}',
                                    colors.textMuted,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                challenge.name,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: colors.textMuted),
                          color: colors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showAbandonDialog(
                                context,
                                ref,
                                challenge,
                                colors,
                              );
                            } else if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateChallengeScreen(
                                    challengeToEdit: challenge,
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                'Edit Mission',
                                style: TextStyle(color: colors.textPrimary),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Abandon Mission',
                                style: TextStyle(
                                  color: AppColors.highPriorityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${challenge.daysRemaining} DAYS REMAINING',
                              style: TextStyle(
                                color: colors.primary.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              '${(challenge.progress * 100).toInt()}%',
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: challenge.progress,
                            minHeight: 6,
                            backgroundColor: colors.progressBarBg,
                            valueColor: AlwaysStoppedAnimation(colors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            InkWell(
              onTap: isTodayCompleted
                  ? null
                  : () {
                      ref
                          .read(challengeProvider.notifier)
                          .toggleCompletion(challenge.id, DateTime.now());
                    },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isTodayCompleted
                      ? colors.primary.withOpacity(0.1)
                      : colors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isTodayCompleted
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: isTodayCompleted ? colors.primary : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isTodayCompleted ? 'MISSION COMPLETED' : 'MARK COMPLETED',
                      style: TextStyle(
                        color: isTodayCompleted ? colors.primary : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact card for completed challenges (no mark-complete button)
  Widget _buildCompletedCard(
    BuildContext context,
    ChallengeModel challenge,
    AppColorScheme colors,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.name,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${challenge.duration} days · ${challenge.completedDates.length} completions',
                      style: TextStyle(color: colors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showAbandonDialog(
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
          'ABANDON MISSION?',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'A True Brother never retreats. Are you sure you want to surrender?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('STAY STRONG', style: TextStyle(color: colors.primary)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(challengeProvider.notifier)
                  .deleteChallenge(challenge.id);
              Navigator.pop(context);
            },
            child: const Text(
              'SURRENDER',
              style: TextStyle(color: AppColors.highPriorityColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieData {
  final String label;
  final double value;
  final Color color;
  _PieData(this.label, this.value, this.color);
}

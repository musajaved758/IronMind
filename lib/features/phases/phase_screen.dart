import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:iron_mind/features/challenge/data/models/challenge_model.dart';

class PhaseScreen extends HookConsumerWidget {
  const PhaseScreen({super.key});

  static const List<Color> operationColors = [
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allChallenges = ref.watch(challengeProvider);
    final activeChallenges = allChallenges
        .where((c) => !c.isCompleted)
        .toList();
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PHASES',
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
        child: activeChallenges.isEmpty
            ? _buildEmptyState(colors)
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: activeChallenges.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 40),
                itemBuilder: (context, index) {
                  final color = operationColors[index % operationColors.length];
                  return _buildRoadmap(
                    activeChallenges[index],
                    context,
                    ref,
                    color,
                    colors,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(AppColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_clock,
            size: 64,
            color: colors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'NO ENGAGEMENT DETECTED',
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

  Widget _buildRoadmap(
    ChallengeModel challenge,
    BuildContext context,
    WidgetRef ref,
    Color accentColor,
    AppColorScheme colors,
  ) {
    final roadmap = challenge.roadmap;
    if (roadmap.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 20),
          child: Text(
            'OPERATION: ${challenge.name.toUpperCase()}',
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roadmap.length,
          itemBuilder: (context, index) {
            final milestone = roadmap[index];
            final isLast = index == roadmap.length - 1;

            bool isLocked = false;
            if (index > 0) {
              if (!challenge.isMilestoneCompleted(index - 1)) {
                isLocked = true;
              }
            }

            return _buildRoadmapItem(
              challenge,
              milestone,
              index, // Pass index for model helper
              index + 1,
              isLast,
              isLocked,
              ref,
              context,
              accentColor,
              colors,
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoadmapItem(
    ChallengeModel challenge,
    ChallengeMilestone milestone,
    int milestoneIndex,
    int stepNumber,
    bool isLast,
    bool isLocked,
    WidgetRef ref,
    BuildContext context,
    Color accentColor,
    AppColorScheme colors,
  ) {
    final isMilestoneDone = challenge.isMilestoneCompleted(milestoneIndex);
    Color primaryColor = isLocked ? colors.textMuted : accentColor;
    Color bgColor = isLocked ? colors.chipBg.withOpacity(0.5) : colors.surface;
    Color textColor = isLocked ? colors.textMuted : colors.textPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isMilestoneDone ? primaryColor : colors.bg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(isLocked ? 0.3 : 1.0),
                  width: 2,
                ),
                boxShadow: isMilestoneDone && !isLocked
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: isLocked
                    ? Icon(Icons.lock, color: colors.textMuted, size: 14)
                    : (milestone.isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : Text(
                              stepNumber.toString().padLeft(2, '0'),
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 200,
                color: isLocked
                    ? colors.divider.withOpacity(0.2)
                    : colors.border.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: milestone.isCompleted
                    ? primaryColor.withOpacity(0.3)
                    : (isLocked
                          ? colors.divider.withOpacity(0.2)
                          : colors.border.withOpacity(0.5)),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Opacity(
              opacity: isLocked ? 0.6 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          bgColor,
                          isLocked
                              ? colors.bg.withOpacity(0.5)
                              : primaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (isLocked)
                          Center(
                            child: Icon(
                              Icons.lock_outline,
                              color: colors.textMuted.withOpacity(0.15),
                              size: 48,
                            ),
                          ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isMilestoneDone
                                  ? colors.chipBg
                                  : primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isLocked
                                  ? 'LOCKED'
                                  : (isMilestoneDone
                                        ? 'COMPLETED'
                                        : 'IN PROGRESS'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Text(
                            'DAYS ${challenge.getMilestoneDayRange(milestoneIndex)[0]}-${challenge.getMilestoneDayRange(milestoneIndex)[1]}',
                            style: TextStyle(
                              color: textColor.withOpacity(0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Text(
                            milestone.title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          milestone.description,
                          style: TextStyle(
                            color: isLocked
                                ? colors.textMuted.withOpacity(0.5)
                                : colors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: colors.textMuted,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${milestone.durationDays} Days Duration',
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (milestone.subtasks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Divider(color: colors.divider.withOpacity(0.3)),
                          const SizedBox(height: 8),
                          Text(
                            'WEEKLY OBJECTIVES',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...milestone.subtasks.map((ChallengeSubtask s) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    isMilestoneDone || s.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isMilestoneDone || s.isCompleted
                                        ? primaryColor
                                        : colors.textMuted,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      s.title,
                                      style: TextStyle(
                                        color: isLocked
                                            ? colors.textMuted.withOpacity(0.5)
                                            : (isMilestoneDone || s.isCompleted
                                                  ? colors.textMuted
                                                  : colors.textSecondary),
                                        fontSize: 12,
                                        decoration:
                                            isMilestoneDone || s.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

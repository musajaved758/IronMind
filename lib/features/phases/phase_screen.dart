import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:operation_brotherhood/features/challenge/data/models/challenge_model.dart';

class PhaseScreen extends HookConsumerWidget {
  const PhaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengeProvider);

    return Scaffold(
      backgroundColor: AppColors.habitBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PHASES',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: challenges.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: challenges.length,
              separatorBuilder: (context, index) => const SizedBox(height: 40),
              itemBuilder: (context, index) {
                return _buildRoadmap(challenges[index], context, ref);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_clock,
            size: 64,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'NO ENGAGEMENT DETECTED',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
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
            style: const TextStyle(
              color: AppColors.habitPrimary,
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

            // Locking Logic:
            // Index 0 is always unlocked.
            // Index N is unlocked if Index N-1 is completed.
            bool isLocked = false;
            if (index > 0) {
              final previousMilestone = roadmap[index - 1];
              if (!previousMilestone.isCompleted) {
                isLocked = true;
              }
            }

            return _buildRoadmapItem(
              challenge,
              milestone,
              index + 1,
              isLast,
              isLocked,
              ref,
              context,
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoadmapItem(
    ChallengeModel challenge,
    ChallengeMilestone milestone,
    int stepNumber,
    bool isLast,
    bool isLocked,
    WidgetRef ref,
    BuildContext context,
  ) {
    Color primaryColor = isLocked ? Colors.grey : AppColors.habitPrimary;
    Color bgColor = isLocked
        ? Colors.white.withOpacity(0.05)
        : AppColors.habitSurface;
    Color textColor = isLocked ? Colors.white38 : Colors.white;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: milestone.isCompleted ? primaryColor : AppColors.habitBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(isLocked ? 0.3 : 1.0),
                  width: 2,
                ),
                boxShadow: milestone.isCompleted && !isLocked
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
                    ? const Icon(Icons.lock, color: Colors.grey, size: 14)
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
                height: 200, // Fixed height for vertical line
                color: isLocked
                    ? Colors.white10
                    : AppColors.habitBorder.withOpacity(0.3),
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
                          ? Colors.white10
                          : AppColors.habitBorder.withOpacity(0.5)),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Opacity(
              opacity: isLocked ? 0.6 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100, // Reduced height
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          bgColor,
                          isLocked
                              ? Colors.black12
                              : primaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (isLocked)
                          const Center(
                            child: Icon(
                              Icons.lock_outline,
                              color: Colors.white10,
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
                              color: milestone.isCompleted
                                  ? Colors.white12
                                  : primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (isLocked)
                                  ? 'LOCKED'
                                  : (milestone.isCompleted
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
                            color: isLocked ? Colors.white30 : Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: isLocked ? Colors.white24 : Colors.grey,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${milestone.durationDays} Days',
                              style: TextStyle(
                                color: isLocked ? Colors.white24 : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (!isLocked)
                              ElevatedButton(
                                onPressed: () {
                                  if (isLocked) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Complete previous phase to unlock!',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  ref
                                      .read(challengeProvider.notifier)
                                      .toggleMilestoneCompletion(
                                        challenge.id,
                                        milestone.id,
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: milestone.isCompleted
                                      ? Colors.white10
                                      : primaryColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  milestone.isCompleted ? 'REDO' : 'COMPLETE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (milestone.subtasks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white10),
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
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: s.isCompleted,
                                      onChanged: isLocked
                                          ? null
                                          : (value) {
                                              ref
                                                  .read(
                                                    challengeProvider.notifier,
                                                  )
                                                  .toggleSubtaskCompletion(
                                                    challenge.id,
                                                    milestone.id,
                                                    s.id,
                                                  );
                                            },
                                      activeColor: primaryColor,
                                      checkColor: Colors.white,
                                      side: BorderSide(
                                        color: isLocked
                                            ? Colors.white30
                                            : Colors.white70,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      s.title,
                                      style: TextStyle(
                                        color: isLocked
                                            ? Colors.white30
                                            : (s.isCompleted
                                                  ? Colors.white38
                                                  : Colors.white70),
                                        fontSize: 12,
                                        decoration: s.isCompleted
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

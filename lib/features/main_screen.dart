import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/widgets/custom_nav_bar.dart';
import 'package:iron_mind/core/utils/barrels/screens.dart';
import 'package:iron_mind/core/providers/app_providers.dart';
import 'package:iron_mind/features/challenge/presentation/screens/challenge_screen.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final isSwapped = ref.watch(swapHomeAndChallengeProvider);
    final hasPhases = ref.watch(hasAnyPhasesProvider);

    // Build pages dynamically — skip PhaseScreen if no phases
    final pages = <Widget>[];

    if (isSwapped) {
      pages.add(const ChallengeScreen());
      pages.add(const HomeScreen());
    } else {
      pages.add(const HomeScreen());
      pages.add(const ChallengeScreen());
    }

    if (hasPhases) {
      pages.add(const PhaseScreen());
    }

    pages.add(const IntelScreen());
    pages.add(const SettingScreen());

    // Clamp index to avoid out-of-bounds
    final safeIndex = currentIndex.clamp(0, pages.length - 1);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: safeIndex,
        onTap: (index) {
          ref.read(navIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}

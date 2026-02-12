import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/core/providers/theme_provider.dart';
import 'package:iron_mind/core/providers/app_providers.dart';

class SettingScreen extends HookConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SETTINGS',
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionHeader('APPEARANCE', colors),
            const SizedBox(height: 16),
            _buildThemeSelector(context, ref, currentTheme, colors),
            const SizedBox(height: 40),
            _sectionHeader('PREFERENCES', colors),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.swap_horiz, color: colors.textSecondary),
                      const SizedBox(width: 16),
                      Text(
                        'Swap Challenges & Habit',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: ref.watch(swapHomeAndChallengeProvider),
                    onChanged: (val) {
                      ref.read(swapHomeAndChallengeProvider.notifier).state =
                          val;
                    },
                    activeColor: colors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: colors.textSecondary),
                      const SizedBox(width: 16),
                      Text(
                        'Show Habit Calendar',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: ref.watch(showHabitCalendarProvider),
                    onChanged: (val) {
                      ref.read(showHabitCalendarProvider.notifier).state = val;
                    },
                    activeColor: colors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag, color: colors.textSecondary),
                      const SizedBox(width: 16),
                      Text(
                        'Max Active Challenges',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                      child: DropdownButton<int>(
                        value: ref.watch(maxChallengesProvider),
                        isDense: true,
                        menuMaxHeight: 250,
                        dropdownColor: colors.dialogBg,
                        borderRadius: BorderRadius.circular(12),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        icon: Icon(
                          Icons.expand_more,
                          color: colors.textSecondary,
                          size: 18,
                        ),
                        items: List.generate(20, (i) => i + 1).map((val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text('$val'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(maxChallengesProvider.notifier).state =
                                val;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _sectionHeader('ABOUT', colors),
            const SizedBox(height: 16),
            _buildInfoCard('Version', '1.0.0', Icons.info_outline, colors),
            const SizedBox(height: 12),
            _buildInfoCard('Developer', 'Coding Geeks', Icons.code, colors),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentTheme,
    AppColorScheme colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            ref,
            'Light Mode',
            Icons.light_mode,
            ThemeMode.light,
            currentTheme == ThemeMode.light,
            colors,
          ),
          Divider(
            color: colors.divider.withOpacity(0.3),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildThemeOption(
            context,
            ref,
            'Dark Mode',
            Icons.dark_mode,
            ThemeMode.dark,
            currentTheme == ThemeMode.dark,
            colors,
          ),
          Divider(
            color: colors.divider.withOpacity(0.3),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildThemeOption(
            context,
            ref,
            'System Default',
            Icons.settings_suggest,
            ThemeMode.system,
            currentTheme == ThemeMode.system,
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    AppColorScheme colors,
  ) {
    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).state = mode;
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withOpacity(0.1)
                    : colors.chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primary, size: 24)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.textSecondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

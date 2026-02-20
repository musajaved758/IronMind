import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/core/providers/theme_provider.dart';
import 'package:iron_mind/core/providers/app_providers.dart';
import 'package:iron_mind/core/services/notification_service.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';

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
            _buildMaxChallengesDropdown(ref, colors),
            const SizedBox(height: 40),
            _sectionHeader('NOTIFICATIONS', colors),
            const SizedBox(height: 16),
            _buildNotificationCard(context, ref, colors),
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
        title.toUpperCase(),
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMaxChallengesDropdown(WidgetRef ref, AppColorScheme colors) {
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
                  return DropdownMenuItem(value: val, child: Text('$val'));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(maxChallengesProvider.notifier).state = val;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    AppColorScheme colors,
  ) {
    final enabled = ref.watch(notificationsEnabledProvider);
    final time = ref.watch(notificationTimeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              Row(
                children: [
                  Icon(Icons.notifications_active, color: colors.textSecondary),
                  const SizedBox(width: 16),
                  Text(
                    'Daily Reminders',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: enabled,
                onChanged: (val) {
                  ref.read(notificationsEnabledProvider.notifier).set(val);
                  _updateNotifications(ref);
                },
                activeColor: colors.primary,
              ),
            ],
          ),
          if (enabled) ...[
            Divider(color: colors.divider.withOpacity(0.3), height: 24),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: colors.primary,
                          onPrimary: Colors.black,
                          surface: colors.surface,
                          onSurface: colors.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  ref.read(notificationTimeProvider.notifier).set(picked);
                  _updateNotifications(ref);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: colors.textSecondary),
                      const SizedBox(width: 16),
                      Text(
                        'Reminder Time',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    time.format(context),
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
      onTap: () => ref.read(themeModeProvider.notifier).state = mode,
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

  void _updateNotifications(WidgetRef ref) {
    final enabled = ref.read(notificationsEnabledProvider);
    if (!enabled) {
      NotificationService.cancelAll();
      return;
    }
    final time = ref.read(notificationTimeProvider);
    final activeChallenge = ref
        .read(challengeProvider.notifier)
        .activeChallenge;
    NotificationService.scheduleDailyNotification(
      time: time,
      activeChallenge: activeChallenge,
    );
  }
}

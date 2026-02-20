import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/core/utils/responsive.dart';
import 'package:iron_mind/core/providers/app_providers.dart';

class CustomNavBar extends HookConsumerWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPhases = ref.watch(hasAnyPhasesProvider);
    final colors = Theme.of(context).appColors;

    // Build nav items dynamically — skip PHASES if no challenge has roadmap
    final items = <_NavItemData>[];

    items.add(_NavItemData(Icons.grid_view_rounded, 'HOME'));
    items.add(_NavItemData(Icons.military_tech_rounded, 'CHALLENGES'));

    if (hasPhases) {
      items.add(_NavItemData(Icons.calendar_today_rounded, 'PHASES'));
    }

    items.add(_NavItemData(Icons.show_chart_rounded, 'PROGRESS'));
    items.add(_NavItemData(Icons.settings_rounded, 'SETTINGS'));

    return Container(
      height: context.hp(10),
      decoration: BoxDecoration(
        color: colors.navBar,
        border: Border(top: BorderSide(color: colors.navBarBorder)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int i = 0; i < items.length; i++)
              _navItem(i, items[i].icon, items[i].label, colors),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String label,
    AppColorScheme colors,
  ) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? colors.iconActive : colors.iconInactive;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  _NavItemData(this.icon, this.label);
}

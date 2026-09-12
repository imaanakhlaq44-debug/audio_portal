import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/theme_controller.dart';
import '../theme/app_theme.dart';

/// Sun / moon button that flips between light and night mode.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark(context);
    return Tooltip(
      message: isDark ? 'Switch to day mode' : 'Switch to night mode',
      child: Material(
        color: c.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => theme.toggle(context),
          child: SizedBox(
            width: 40,
            height: 40,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: FadeTransition(opacity: anim, child: child)),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                color: isDark ? c.secondary : c.tertiary,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

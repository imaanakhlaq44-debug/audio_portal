import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'theme_toggle_button.dart';

/// Logo, page title and night-mode toggle across the top of a tab, matching
/// the Library tab's header.
class BrandTopBar extends StatelessWidget {
  final String title;

  const BrandTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: c.surfaceLowest,
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/icon/app_icon.webp',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTheme.headline(size: 20, color: c.primaryDeep),
            ),
          ),
          const ThemeToggleButton(),
        ],
      ),
    );
  }
}

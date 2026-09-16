import 'package:flutter/material.dart';

import '../models/story_category.dart';
import '../theme/app_theme.dart';

/// Colorful rounded category tile used in the Explore Categories grid.
class CategoryCard extends StatelessWidget {
  final StoryCategory category;
  final VoidCallback onTap;
  final int? count;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.count,
  });

  ({Color bg, Color fg}) _colors(AppColors c) {
    switch (category) {
      case StoryCategory.prophets:
        return (bg: c.primaryFixed, fg: c.primary);
      case StoryCategory.moral:
        return (bg: c.secondaryFixed, fg: c.secondaryDeep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final colors = _colors(c);
    final label = count == null
        ? category.label
        : '${category.label}, $count series';
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: colors.bg,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: c.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category.icon, size: 44, color: colors.fg),
                  const SizedBox(height: 10),
                  Text(
                    category.label,
                    style: AppTheme.body(
                      size: 14,
                      weight: FontWeight.w700,
                      color: c.onSurface,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$count series',
                      style: AppTheme.body(size: 12, color: c.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

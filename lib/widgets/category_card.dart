import 'package:flutter/material.dart';
import '../models/story_category.dart';
import '../theme/app_theme.dart';

/// Colorful rounded category tile used in the Explore Categories grid,
/// matching the Stitch design (soft tinted backgrounds per category).
class CategoryCard extends StatelessWidget {
  final StoryCategory category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  ({Color bg, Color fg}) get _colors {
    switch (category) {
      case StoryCategory.prophets:
        return (bg: AppTheme.primaryFixed, fg: AppTheme.primaryPink);
      case StoryCategory.animals:
        return (bg: AppTheme.secondaryFixed, fg: AppTheme.secondaryOrangeDeep);
      case StoryCategory.nature:
        return (bg: AppTheme.tertiaryFixed, fg: AppTheme.tertiaryBlue);
      case StoryCategory.bedtime:
        return (bg: AppTheme.surfaceContainerHigh, fg: AppTheme.primaryPink);
      case StoryCategory.moral:
        return (bg: AppTheme.surfaceVariant, fg: AppTheme.primaryPinkDeep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.outlineVariant.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 44, color: c.fg),
              const SizedBox(height: 10),
              Text(
                category.label,
                style: AppTheme.body(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

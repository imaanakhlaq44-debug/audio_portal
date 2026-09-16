import 'package:flutter/material.dart';

import '../models/story_category.dart';
import '../models/story_data.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/series_card.dart';

/// Every series in one category, as a grid of covers.
class CategoryStoriesScreen extends StatelessWidget {
  final StoryCategory category;
  const CategoryStoriesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final series = StoryData.seriesIn(category);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(category.label),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${series.length} series',
                style: AppTheme.body(size: 13, color: c.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
      // Leave room for the mini-player which lives on MainScreen; here we
      // show our own so playback controls stay reachable on this route too.
      bottomNavigationBar: const SafeArea(child: MiniPlayer()),
      body: SafeArea(
        bottom: false,
        child: series.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category.icon, size: 56, color: c.outlineVariant),
                    const SizedBox(height: 14),
                    Text(
                      'More stories coming soon!',
                      style: AppTheme.body(color: c.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 16.0;
                  final width = (constraints.maxWidth - 40 - gap) / 2;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final s in series)
                          SeriesCard(series: s, width: width),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

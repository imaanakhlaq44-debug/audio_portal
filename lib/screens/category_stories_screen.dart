import 'package:flutter/material.dart';

import '../models/story_category.dart';
import '../models/story_data.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/story_tile.dart';

class CategoryStoriesScreen extends StatelessWidget {
  final StoryCategory category;
  const CategoryStoriesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final stories = StoryData.byCategory(category);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(category.label),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${stories.length} ${stories.length == 1 ? 'story' : 'stories'}',
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
        child: stories.isEmpty
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
            : ListView(
                padding: const EdgeInsets.all(20),
                children: stories
                    .map(
                      (story) => StoryTile(
                        story: story,
                        onTap: () => openStory(context, story),
                        onPlay: () => togglePlayFor(context, story),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

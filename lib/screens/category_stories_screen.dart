import 'package:flutter/material.dart';
import '../models/story_category.dart';
import '../models/story_data.dart';
import '../services/audio_player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/story_tile.dart';

class CategoryStoriesScreen extends StatelessWidget {
  final StoryCategory category;
  const CategoryStoriesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final stories = StoryData.byCategory(category);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(category.label)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: stories.isEmpty
              ? [
                  const SizedBox(height: 60),
                  Center(
                    child: Text(
                      'More stories coming soon!',
                      style: AppTheme.body(color: AppTheme.onSurfaceVariant),
                    ),
                  ),
                ]
              : stories
                    .map(
                      (story) => StoryTile(
                        story: story,
                        onTap: () =>
                            AudioPlayerService.instance.playStory(story),
                        onPlay: () =>
                            AudioPlayerService.instance.playStory(story),
                      ),
                    )
                    .toList(),
        ),
      ),
    );
  }
}

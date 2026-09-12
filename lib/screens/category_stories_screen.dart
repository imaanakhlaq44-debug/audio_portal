import 'package:flutter/material.dart';
import '../models/story_category.dart';
import '../models/story_data.dart';
import '../services/audio_player_service.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/story_tile.dart';

/// Start the story (if not already loaded) and open the Now Playing screen.
Future<void> _openStory(BuildContext context, Story story) async {
  final player = AudioPlayerService.instance;
  if (player.currentStory?.id != story.id) await player.playStory(story);
  if (context.mounted) openNowPlaying(context);
}

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
                        onTap: () => _openStory(context, story),
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

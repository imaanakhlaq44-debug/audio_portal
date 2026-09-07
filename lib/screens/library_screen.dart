import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/story_category.dart';
import '../models/story_data.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/story_tile.dart';
import 'category_stories_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Story> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchResults = StoryData.search(value);
    });
  }

  void _openCategory(StoryCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryStoriesScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favIds = StorageService.getFavorites();
    final libraryStories = StoryData.allStories
        .where(
          (s) => favIds.contains(s.id) || StorageService.isDownloaded(s.id),
        )
        .toList();
    final showingSearch = _searchController.text.trim().isNotEmpty;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppTheme.background,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/child_avatar.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Imaan & Akhlaq',
                    style: AppTheme.headline(
                      size: 20,
                      color: AppTheme.primaryPinkDeep,
                    ),
                  ),
                ),
                Icon(Icons.verified, color: AppTheme.primaryPinkDeep),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Search bar ----
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Find stories, du'as, and more...",
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (showingSearch)
                    ..._buildSearchResults()
                  else
                    ..._buildBrowseContent(libraryStories),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return [
        const SizedBox(height: 40),
        Center(
          child: Text(
            'No stories found',
            style: AppTheme.body(color: AppTheme.onSurfaceVariant),
          ),
        ),
      ];
    }
    return [
      Text('Search Results', style: AppTheme.headline(size: 20)),
      const SizedBox(height: 14),
      ..._searchResults.map(
        (story) => StoryTile(
          story: story,
          onTap: () => AudioPlayerService.instance.playStory(story),
          onPlay: () => AudioPlayerService.instance.playStory(story),
        ),
      ),
    ];
  }

  List<Widget> _buildBrowseContent(List<Story> libraryStories) {
    return [
      Text('Explore Categories', style: AppTheme.headline(size: 20)),
      const SizedBox(height: 14),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        children: StoryCategory.values
            .map(
              (c) => CategoryCard(category: c, onTap: () => _openCategory(c)),
            )
            .toList(),
      ),
      const SizedBox(height: 28),
      Text('My Library', style: AppTheme.headline(size: 20)),
      const SizedBox(height: 14),
      if (libraryStories.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 44,
                  color: AppTheme.outlineVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'Save stories with the heart icon\nto find them here!',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        )
      else
        ...libraryStories.map(
          (story) => StoryTile(
            story: story,
            onTap: () => AudioPlayerService.instance.playStory(story),
            onPlay: () => AudioPlayerService.instance.playStory(story),
          ),
        ),
    ];
  }
}

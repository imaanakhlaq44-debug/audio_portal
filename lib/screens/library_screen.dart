import 'package:flutter/material.dart';

import '../models/story.dart';
import '../models/story_category.dart';
import '../models/story_data.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/mini_player.dart';
import '../widgets/story_tile.dart';
import '../widgets/theme_toggle_button.dart';
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
    setState(() => _searchResults = StoryData.search(value));
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    FocusScope.of(context).unfocus();
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
    final c = context.colors;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
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
                    'Qissora',
                    style: AppTheme.headline(size: 20, color: c.primaryDeep),
                  ),
                ),
                const ThemeToggleButton(),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: StorageService.favoritesListenable(),
              builder: (context, _, __) => _buildBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final c = context.colors;
    final favIds = StorageService.getFavorites();
    final savedIds = StorageService.getSavedStories();
    final libraryStories = StoryData.allStories
        .where((s) => favIds.contains(s.id) || savedIds.contains(s.id))
        .toList();
    final showingSearch = _searchController.text.trim().isNotEmpty;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            style: AppTheme.body(size: 15, color: c.onSurface),
            decoration: InputDecoration(
              hintText: "Find stories, du'as, and more...",
              prefixIcon: Icon(Icons.search, color: c.onSurfaceVariant),
              suffixIcon: showingSearch
                  ? IconButton(
                      tooltip: 'Clear search',
                      icon: Icon(Icons.close, color: c.onSurfaceVariant),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          if (showingSearch)
            ..._buildSearchResults(c)
          else
            ..._buildBrowseContent(c, libraryStories),
        ],
      ),
    );
  }

  List<Widget> _buildSearchResults(AppColors c) {
    if (_searchResults.isEmpty) {
      return [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 44, color: c.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'No stories found',
                style: AppTheme.body(color: c.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      Text(
        'Search Results (${_searchResults.length})',
        style: AppTheme.headline(size: 20, color: c.headline),
      ),
      const SizedBox(height: 14),
      ..._searchResults.map(
        (story) => StoryTile(
          story: story,
          onTap: () => openStory(context, story),
          onPlay: () => togglePlayFor(context, story),
        ),
      ),
    ];
  }

  List<Widget> _buildBrowseContent(AppColors c, List<Story> libraryStories) {
    return [
      Text(
        'Explore Categories',
        style: AppTheme.headline(size: 20, color: c.headline),
      ),
      const SizedBox(height: 14),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        children: StoryCategory.values
            .map(
              (cat) => CategoryCard(
                category: cat,
                count: StoryData.seriesIn(cat).length,
                onTap: () => _openCategory(cat),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 28),
      Text('My Library', style: AppTheme.headline(size: 20, color: c.headline)),
      const SizedBox(height: 14),
      if (libraryStories.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.surfaceLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.auto_stories, size: 44, color: c.outlineVariant),
                const SizedBox(height: 12),
                Text(
                  'Save stories with the heart icon\nto find them here!',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(color: c.onSurfaceVariant),
                ),
              ],
            ),
          ),
        )
      else
        ...libraryStories.map(
          (story) => StoryTile(
            story: story,
            onTap: () => openStory(context, story),
            onPlay: () => togglePlayFor(context, story),
          ),
        ),
    ];
  }
}

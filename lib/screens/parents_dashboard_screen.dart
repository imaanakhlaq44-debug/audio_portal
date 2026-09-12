import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/story_data.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Simple parents dashboard shown after successful PIN entry:
/// change PIN, edit child's name, and see app info.
class ParentsDashboardScreen extends StatefulWidget {
  const ParentsDashboardScreen({super.key});

  @override
  State<ParentsDashboardScreen> createState() => _ParentsDashboardScreenState();
}

class _ParentsDashboardScreenState extends State<ParentsDashboardScreen> {
  void _showChangePinDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set New PIN', style: AppTheme.headline(size: 18)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(hintText: 'Enter 4-digit PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final pin = controller.text.trim();
              // Must be exactly 4 digits (maxLength alone doesn't stop
              // letters/spaces from being saved as the PIN).
              if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('PIN must be exactly 4 digits'),
                    backgroundColor: AppTheme.error,
                  ),
                );
                return;
              }
              await StorageService.setParentPin(pin);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN updated successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangeNameDialog() {
    final controller = TextEditingController(
      text: StorageService.getChildName(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Child's Name", style: AppTheme.headline(size: 18)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter child's name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await StorageService.setChildName(controller.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStoryListDialog({
    required String title,
    required List<String> ids,
    required Future<void> Function() onClear,
  }) {
    final stories = ids
        .map(StoryData.byId)
        .whereType<Story>()
        .toList(growable: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTheme.headline(size: 18)),
        content: stories.isEmpty
            ? Text(
                'Nothing here yet.',
                style: AppTheme.body(color: AppTheme.onSurfaceVariant),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: stories
                      .map(
                        (s) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              s.coverAsset,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            s.title,
                            style: AppTheme.body(
                              size: 14,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
        actions: [
          if (stories.isNotEmpty)
            TextButton(
              onPressed: () async {
                await onClear();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text(
                'Clear all',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Parents Dashboard')),
      body: SafeArea(
        // Live-updates the counters/name whenever storage changes.
        child: ValueListenableBuilder(
          valueListenable: StorageService.listenable(),
          builder: (context, _, __) {
            final favs = StorageService.getFavorites();
            final downloads = StorageService.getDownloads();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionCard(
                  icon: Icons.child_care,
                  title: "Child's Name",
                  subtitle: StorageService.getChildName(),
                  onTap: _showChangeNameDialog,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons.lock_reset,
                  title: 'Change Parents PIN',
                  subtitle: 'Update the 4-digit access code',
                  onTap: _showChangePinDialog,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons.favorite_outline,
                  title: 'Saved Favorites',
                  subtitle:
                      '${favs.length} ${favs.length == 1 ? 'story' : 'stories'} saved',
                  onTap: () => _showStoryListDialog(
                    title: 'Saved Favorites',
                    ids: favs,
                    onClear: StorageService.clearFavorites,
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons.download_outlined,
                  title: 'Downloaded Stories',
                  subtitle:
                      '${downloads.length} ${downloads.length == 1 ? 'story' : 'stories'} saved offline',
                  onTap: () => _showStoryListDialog(
                    title: 'Downloaded Stories',
                    ids: downloads,
                    onClear: StorageService.clearDownloads,
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    'Imaan & Akhlaq v1.0.0',
                    style: AppTheme.body(size: 12, color: AppTheme.outline),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primaryPink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.body(
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.body(
                      size: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }
}

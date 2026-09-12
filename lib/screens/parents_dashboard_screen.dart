import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../models/story_data.dart';
import '../services/storage_service.dart';
import '../services/theme_controller.dart';
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
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Set New PIN',
          style: AppTheme.headline(size: 18, color: c.headline),
        ),
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
                  SnackBar(
                    content: const Text('PIN must be exactly 4 digits'),
                    backgroundColor: c.error,
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
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Child's Name",
          style: AppTheme.headline(size: 18, color: c.headline),
        ),
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
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: AppTheme.headline(size: 18, color: c.headline),
        ),
        content: stories.isEmpty
            ? Text(
                'Nothing here yet.',
                style: AppTheme.body(color: c.onSurfaceVariant),
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
                            style: AppTheme.body(size: 14, color: c.onSurface),
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
              child: Text('Clear all', style: TextStyle(color: c.error)),
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
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: const Text('Parents Dashboard')),
      body: SafeArea(
        // Live-updates the counters/name whenever storage changes
        // (settings box for name/pin/favs, progress box for listen stats).
        child: ValueListenableBuilder(
          valueListenable: StorageService.settingsListenable(),
          builder: (context, _, _) => ValueListenableBuilder(
            valueListenable: StorageService.progressListenable(),
            builder: (context, _, _) => _buildBody(context, c),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppColors c) {
    final favs = StorageService.getFavorites();
    final downloads = StorageService.getDownloads();
    final plays = StorageService.totalPlays();
    final completed = StorageService.completedCount();
    final theme = context.watch<ThemeController>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ---- Listening stats ----
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.headphones,
                value: '$plays',
                label: plays == 1 ? 'Listen' : 'Listens',
                tint: c.secondaryFixed,
                fg: c.secondaryDeep,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline,
                value: '$completed / ${StoryData.allStories.length}',
                label: 'Completed',
                tint: c.tertiaryFixed,
                fg: c.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
        const SizedBox(height: 14),
        _SectionCard(
          icon: c.isDark ? Icons.dark_mode : Icons.light_mode,
          title: 'Night Mode',
          subtitle: switch (theme.mode) {
            ThemeMode.dark => 'Always on',
            ThemeMode.light => 'Always off',
            ThemeMode.system => 'Follows phone setting',
          },
          onTap: _showThemeDialog,
        ),
        const SizedBox(height: 14),
        _SectionCard(
          icon: Icons.restart_alt,
          title: 'Reset Listening History',
          subtitle: 'Clear progress & play counts for all stories',
          onTap: _confirmResetProgress,
        ),
        const SizedBox(height: 28),
        Center(
          child: Text(
            'Imaan & Akhlaq v1.1.0',
            style: AppTheme.body(size: 12, color: c.outline),
          ),
        ),
      ],
    );
  }

  void _showThemeDialog() {
    final theme = context.read<ThemeController>();
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(
          'Night Mode',
          style: AppTheme.headline(size: 18, color: c.headline),
        ),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: theme.mode,
            onChanged: (m) {
              if (m != null) theme.setMode(m);
              Navigator.pop(ctx);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in const [
                  (
                    ThemeMode.system,
                    'Follow phone setting',
                    Icons.phone_android,
                  ),
                  (ThemeMode.light, 'Always light', Icons.light_mode),
                  (ThemeMode.dark, 'Always dark', Icons.dark_mode),
                ])
                  RadioListTile<ThemeMode>(
                    value: entry.$1,
                    activeColor: c.primaryDeep,
                    secondary: Icon(entry.$3, color: c.onSurfaceVariant),
                    title: Text(
                      entry.$2,
                      style: AppTheme.body(size: 14, color: c.onSurface),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetProgress() {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Reset Listening History?',
          style: AppTheme.headline(size: 18, color: c.headline),
        ),
        content: Text(
          'This clears "continue listening" positions and play counts for '
          'every story. Favorites and downloads are kept.',
          style: AppTheme.body(size: 14, color: c.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearAllProgress();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listening history cleared')),
                );
              }
            },
            child: Text('Reset', style: TextStyle(color: c.error)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color tint;
  final Color fg;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(height: 10),
          Text(value, style: AppTheme.headline(size: 22, color: c.headline)),
          Text(
            label,
            style: AppTheme.body(size: 12, color: c.onSurfaceVariant),
          ),
        ],
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
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surfaceLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: c.outlineVariant.withValues(alpha: c.isDark ? 0.5 : 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: c.primaryFixed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: c.primaryDeep),
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
                      color: c.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.body(size: 13, color: c.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.outline),
          ],
        ),
      ),
    );
  }
}

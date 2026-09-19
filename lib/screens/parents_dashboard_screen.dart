import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../models/story.dart';
import '../models/story_data.dart';
import '../services/premium_service.dart';
import '../services/storage_service.dart';
import '../services/theme_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/paywall_sheet.dart';

/// Google Play's page for managing this app's subscription.
final Uri _manageSubscriptionUri = Uri.parse(
  'https://play.google.com/store/account/subscriptions'
  '?package=com.imaanakhlaq.qissora',
);

/// Simple parents dashboard shown after successful PIN entry:
/// change PIN, edit child's name, and see app info.
class ParentsDashboardScreen extends StatefulWidget {
  const ParentsDashboardScreen({super.key});

  @override
  State<ParentsDashboardScreen> createState() => _ParentsDashboardScreenState();
}

class _ParentsDashboardScreenState extends State<ParentsDashboardScreen> {
  void _showChangePinDialog() {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Set New PIN',
          style: AppTheme.headline(size: 18, color: c.headline),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(hintText: 'New 4-digit PIN'),
            ),
            // Asking twice: a typo here would lock the parent out of their
            // own dashboard with no way to recover it.
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(hintText: 'Repeat the PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              final confirm = confirmController.text.trim();

              // Must be exactly 4 digits (maxLength alone doesn't stop
              // letters/spaces from being saved as the PIN).
              String? problem;
              if (!StorageService.isFourDigitPin(pin)) {
                problem = 'PIN must be exactly 4 digits';
              } else if (pin != confirm) {
                problem = 'The two PINs do not match';
              }
              if (problem != null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(problem), backgroundColor: c.error),
                );
                return;
              }

              await StorageService.setParentPin(pin);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                setState(() {});
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
    final saved = StorageService.getSavedStories();
    final plays = StorageService.totalPlays();
    final completed = StorageService.completedCount();
    final theme = context.watch<ThemeController>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _AccountCard(),
        const SizedBox(height: 20),

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
          subtitle: StorageService.isUsingDefaultPin()
              ? 'Still the default PIN - tap to change it'
              : 'Update the 4-digit access code',
          onTap: _showChangePinDialog,
          warn: StorageService.isUsingDefaultPin(),
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
          icon: Icons.bookmark_border,
          title: 'Saved Stories',
          subtitle:
              '${saved.length} ${saved.length == 1 ? 'story' : 'stories'} in the library',
          onTap: () => _showStoryListDialog(
            title: 'Saved Stories',
            ids: saved,
            onClear: StorageService.clearSavedStories,
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
            '$appName v$appVersion',
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
          'every story. Favorites and saved stories are kept.',
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

/// The family's plan and Google account: upgrade, restore a subscription
/// bought before, or manage it in Google Play.
class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumService>();
    final isPremium = premium.isPremium;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPremium
              ? [AppColors.light.secondary, AppColors.light.secondaryDeep]
              : [AppColors.light.headline, AppColors.light.tertiary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPremium ? Icons.workspace_premium : Icons.person_outline,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'Qissora Premium' : 'Free plan',
                      style: AppTheme.headline(size: 18, color: Colors.white),
                    ),
                    Text(
                      isPremium
                          ? 'Every episode is unlocked'
                          : 'Episode 1 of each series, as a preview',
                      style: AppTheme.body(
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isPremium)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => showPaywall(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.light.secondary,
                ),
                icon: const Icon(Icons.lock_open_rounded, size: 20),
                label: const Text('Get Premium'),
              ),
            ),
          Wrap(
            spacing: 4,
            children: [
              if (!isPremium)
                _AccountAction(
                  label: 'Restore purchase',
                  onTap: () =>
                      runPremiumAction(context, premium.restore, gate: false),
                ),
              _AccountAction(
                label: 'Manage subscription',
                onTap: () => launchUrl(
                  _manageSubscriptionUri,
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          if (premium.accountEmail case final email?) ...[
            const Divider(color: Colors.white24, height: 20),
            Row(
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(
                      size: 13,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 4,
              children: [
                _AccountAction(label: 'Sign out', onTap: premium.signOut),
                _AccountAction(
                  label: 'Delete account',
                  onTap: () => _confirmDeleteAccount(context, premium),
                ),
              ],
            ),
          ] else ...[
            const Divider(color: Colors.white24, height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                // The Parents area is already behind the PIN, so no
                // grown-up question here.
                onPressed: () =>
                    runPremiumAction(context, premium.signIn, gate: false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text('Sign in with Google'),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'New phone? Sign in to get your Premium back.',
              style: AppTheme.body(
                size: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Removes the Google account from Qissora, after saying plainly that the
/// subscription itself is cancelled in Google Play.
Future<void> _confirmDeleteAccount(
  BuildContext context,
  PremiumService premium,
) async {
  final c = context.colors;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete account?'),
      content: const Text(
        'This signs your Google account out of Qissora and removes its '
        'access. It does not cancel a subscription: to stop paying, use '
        '"Manage subscription" in Google Play.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Delete', style: TextStyle(color: c.error)),
        ),
      ],
    ),
  );
  if (ok != true) return;
  await premium.deleteAccount();
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account removed')));
  }
}

class _AccountAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AccountAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
        ),
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

  /// Draws the card in the warning colour - used for the "you are still on
  /// the default PIN" nudge.
  final bool warn;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.warn = false,
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
            color: warn
                ? c.error.withValues(alpha: 0.55)
                : c.outlineVariant.withValues(alpha: c.isDark ? 0.5 : 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: warn ? c.error.withValues(alpha: 0.12) : c.primaryFixed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: warn ? c.error : c.primaryDeep),
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
                    style: AppTheme.body(
                      size: 13,
                      color: warn ? c.error : c.onSurfaceVariant,
                    ),
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

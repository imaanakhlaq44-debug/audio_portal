import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // App Settings Section
          _buildSectionHeader('App Settings'),
          _buildSettingTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage task reminders',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications settings coming soon!')),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: 'Light mode',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme settings coming soon!')),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings coming soon!')),
              );
            },
          ),
          
          const Divider(height: 32),
          
          // Family Settings Section
          _buildSectionHeader('Family Settings'),
          _buildSettingTile(
            context,
            icon: Icons.family_restroom,
            title: 'Manage Family',
            subtitle: '4 members',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Family management coming soon!')),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.card_giftcard_outlined,
            title: 'Rewards Store',
            subtitle: 'Set up rewards for points',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rewards store coming soon!')),
              );
            },
          ),
          
          const Divider(height: 32),
          
          // Data & Privacy Section
          _buildSectionHeader('Data & Privacy'),
          _buildSettingTile(
            context,
            icon: Icons.download_outlined,
            title: 'Export Data',
            subtitle: 'Download your data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export coming soon!')),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Backup & Sync',
            subtitle: 'Cloud backup disabled',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup settings coming soon!')),
              );
            },
          ),
          
          const Divider(height: 32),
          
          // About Section
          _buildSectionHeader('About'),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'About Chore Tracker',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Chore Tracker',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                children: [
                  const Text(
                    'A modern family household task management app that helps families coordinate chores, track progress, and reward achievements.',
                  ),
                ],
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with the app',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & support coming soon!')),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon!')),
              );
            },
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textMedium,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryOrange,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textMedium,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textLight,
      ),
      onTap: onTap,
    );
  }
}

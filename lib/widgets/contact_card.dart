import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

/// The team's WhatsApp number, as shown to people.
const String contactWhatsAppDisplay = '+92 333 5756028';

/// wa.me opens the chat in the WhatsApp app when it is installed, and in the
/// browser otherwise.
final Uri contactWhatsAppUri = Uri.parse('https://wa.me/923335756028');

/// Opens a WhatsApp chat with the team, or explains why it could not.
Future<void> openWhatsApp(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  var opened = false;
  try {
    opened = await launchUrl(
      contactWhatsAppUri,
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    opened = false;
  }
  if (!opened) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open WhatsApp. Message us on $contactWhatsAppDisplay',
        ),
      ),
    );
  }
}

/// A brand-gradient card that invites parents to message the team.
class ContactCard extends StatelessWidget {
  final String title;
  final String message;

  const ContactCard({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Night mode lightens headline and tertiary for text, which would
          // wash out this white-on-navy card, so it keeps the day colours.
          colors: [AppColors.light.headline, AppColors.light.tertiary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.shadow.withValues(alpha: c.isDark ? 0.3 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.headline(size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: AppTheme.body(
              size: 14,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => openWhatsApp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.secondary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.chat, size: 20),
              label: Text(
                'Contact Us on WhatsApp',
                style: AppTheme.body(
                  size: 15,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              contactWhatsAppDisplay,
              style: AppTheme.body(
                size: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

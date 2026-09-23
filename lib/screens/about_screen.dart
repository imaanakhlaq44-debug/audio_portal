import 'package:flutter/material.dart';

import '../app_info.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_top_bar.dart';
import '../widgets/contact_card.dart';

/// Who Imaan & Akhlaq are: the programme's vision, objectives and stages.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const BrandTopBar(title: 'About Us'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                const _HeroCard(),
                const SizedBox(height: 28),

                const SectionTitle(
                  icon: Icons.people_alt_outlined,
                  title: 'Guided by Imaan & Akhlaq',
                  subtitle:
                      'Interactive characters in our educational '
                      'experiences.',
                ),
                const SizedBox(height: 14),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _CharacterCard(
                          name: 'Imaan',
                          meaning: 'Faith',
                          icon: Icons.mosque_outlined,
                          tint: c.primaryFixed,
                          fg: c.primaryDeep,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CharacterCard(
                          name: 'Akhlaq',
                          meaning: 'Character',
                          icon: Icons.volunteer_activism_outlined,
                          tint: c.secondaryFixed,
                          fg: c.secondaryDeep,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                const SectionTitle(
                  icon: Icons.visibility_outlined,
                  title: 'Our Vision',
                ),
                const SizedBox(height: 14),
                const _VisionCard(),
                const SizedBox(height: 28),

                const SectionTitle(
                  icon: Icons.menu_book_outlined,
                  title: 'Introduction',
                ),
                const SizedBox(height: 14),
                const _IntroductionCard(),
                const SizedBox(height: 28),

                const SectionTitle(
                  icon: Icons.flag_outlined,
                  title: 'Core Objectives',
                ),
                const SizedBox(height: 14),
                const _ObjectivesGrid(),
                const SizedBox(height: 28),

                const SectionTitle(
                  icon: Icons.trending_up,
                  title: 'Progression Focus',
                  subtitle: 'How the programme grows with your child.',
                ),
                const SizedBox(height: 14),
                const _ProgressionTimeline(),
                const SizedBox(height: 28),

                const ContactCard(
                  title: 'Get in Touch',
                  message:
                      'Questions, feedback or want Imaan & Akhlaq in '
                      'your school? We would love to hear from you.',
                ),
                const SizedBox(height: 28),

                Center(
                  child: Text(
                    'Imaan & Akhlaq — Nurturing Faith & Character',
                    textAlign: TextAlign.center,
                    style: AppTheme.body(
                      size: 13,
                      weight: FontWeight.w600,
                      color: c.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '$appName v$appVersion',
                    style: AppTheme.body(size: 12, color: c.outline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon, heading and optional line of explanation above a group of cards.
class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: c.primaryDeep),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTheme.headline(size: 20, color: c.headline),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTheme.body(size: 13, color: c.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

/// The white card with a soft border that most sections sit in.
class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: c.outlineVariant.withValues(alpha: c.isDark ? 0.5 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: c.shadow.withValues(alpha: c.isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // The day brand pinks in both themes: night mode's softer pinks are
          // too pale behind white text.
          colors: [AppColors.light.primary, AppColors.light.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: c.primaryDeep.withValues(alpha: c.isDark ? 0.25 : 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Soft orange glows in the corners, from the brand's secondary.
          Positioned(
            right: -40,
            top: -40,
            child: _Glow(color: c.secondary, size: 150),
          ),
          Positioned(
            left: -30,
            bottom: -50,
            child: _Glow(color: c.secondary, size: 120),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon/app_icon.webp',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Imaan & Akhlaq',
                            style: AppTheme.headline(
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Nurturing Faith & Character',
                            style: AppTheme.body(
                              size: 13,
                              weight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Rooted in timeless Islamic values, Imaan & Akhlaq brings to '
                  'life the inspiring journey of two siblings — Imaan (faith) '
                  'and Akhlaq (character) — who guide young learners to live '
                  'with courage, kindness, and integrity.',
                  style: AppTheme.body(
                    size: 15,
                    color: Colors.white,
                  ).copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _HeroChip(label: 'Courage'),
                    _HeroChip(label: 'Kindness'),
                    _HeroChip(label: 'Integrity'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;

  const _HeroChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTheme.body(
          size: 12,
          weight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final String name;
  final String meaning;
  final IconData icon;
  final Color tint;
  final Color fg;

  const _CharacterCard({
    required this.name,
    required this.meaning,
    required this.icon,
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.surfaceLowest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: fg),
          ),
          const SizedBox(height: 12),
          Text(name, style: AppTheme.headline(size: 20, color: c.headline)),
          Text(
            meaning,
            style: AppTheme.body(size: 13, weight: FontWeight.w600, color: fg),
          ),
        ],
      ),
    );
  }
}

class _VisionCard extends StatelessWidget {
  const _VisionCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: c.tertiaryFixed,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: c.tertiary, width: 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, size: 32, color: c.tertiary),
          const SizedBox(height: 6),
          Text(
            'To nurture a generation of confident, responsible, and virtuous '
            'Muslims by embedding Imaan (faith) and Akhlaq (character) at the '
            'heart of education, enabling young learners to live with '
            'courage, kindness, and integrity in every aspect of life.',
            style: AppTheme.body(
              size: 15,
              weight: FontWeight.w500,
              color: c.headline,
            ).copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _IntroductionCard extends StatelessWidget {
  const _IntroductionCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final para = AppTheme.body(
      size: 14,
      color: c.onSurfaceVariant,
    ).copyWith(height: 1.6);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Designed as more than just a curriculum, the program offers a '
            'holistic learning experience that seamlessly blends structured '
            'books, engaging coloring activities, and prophetic storytelling '
            'with modern tools such as games, animations, and school-based '
            'clubs.',
            style: para,
          ),
          const SizedBox(height: 12),
          Text(
            'At its core, Imaan & Akhlaq aims to develop children into moral '
            'figures of Uswah e Hasana.',
            style: para,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.secondaryFixed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.rocket_launch_outlined, color: c.secondaryDeep),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Following the success of pilot implementations, the '
                    'program is set for a nationwide launch in 2026!',
                    style: AppTheme.body(
                      size: 13,
                      weight: FontWeight.w600,
                      color: c.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectivesGrid extends StatelessWidget {
  const _ObjectivesGrid();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = [
      (
        '❤️',
        'Character-Centered',
        'Develop strong moral character by integrating Islamic values into '
            'everyday learning and behavior.',
        c.primaryFixed,
      ),
      (
        '🎮',
        'Holistic Learning',
        'Combining curriculum, storytelling, activities, and interactive '
            'tools for engaging education.',
        c.secondaryFixed,
      ),
      (
        '🕌',
        'Faith Integration',
        "Strengthening children's connection with Islamic teachings through "
            'prophetic stories.',
        c.tertiaryFixed,
      ),
      (
        '🌟',
        'Behavior Transformation',
        'Inspiring courage, kindness, responsibility, and integrity in '
            'real-life situations.',
        c.surfaceHigh,
      ),
    ];
    Widget card((String, String, String, Color) o) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: o.$4,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.surfaceLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(o.$1, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 10),
          Text(
            o.$2,
            style: AppTheme.body(
              size: 14,
              weight: FontWeight.w700,
              color: c.headline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            o.$3,
            style: AppTheme.body(
              size: 12,
              color: c.onSurfaceVariant,
            ).copyWith(height: 1.45),
          ),
        ],
      ),
    );
    Widget row(int i) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: card(items[i])),
          const SizedBox(width: 12),
          Expanded(child: card(items[i + 1])),
        ],
      ),
    );
    return Column(children: [row(0), const SizedBox(height: 12), row(2)]);
  }
}

class _ProgressionTimeline extends StatelessWidget {
  const _ProgressionTimeline();

  static const _stages = [
    (
      'Foundation Stage',
      'Ages 5 – 8',
      'Foundational character building through storytelling, basic activity '
          'modules, and an introduction to prophetic narratives.',
    ),
    (
      'Interactive Stage',
      'Ages 9 – 10',
      'Interactive development with advanced club engagements, '
          'responsibility focus, and group tasks.',
    ),
    (
      'Ethical Maturation',
      'Ages 11 – 13',
      'Real-world scenarios, peer mentoring, and leadership grounded in '
          'prophetic stories.',
    ),
    (
      'Uswah e Hasana',
      'Ages 14+',
      'Embodying character, leading clubs, and complex behavioral '
          'transformation.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Each stage steps from pink towards orange, so the timeline reads as
    // growth.
    final accents = [
      c.primary,
      Color.lerp(c.primary, c.secondary, 0.35)!,
      Color.lerp(c.primary, c.secondary, 0.7)!,
      c.secondary,
    ];
    return Column(
      children: [
        for (var i = 0; i < _stages.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accents[i],
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTheme.body(
                            size: 14,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (i < _stages.length - 1)
                        Expanded(
                          child: Container(
                            width: 3,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [accents[i], accents[i + 1]],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < _stages.length - 1 ? 14 : 0,
                    ),
                    child: _Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _stages[i].$1,
                                  style: AppTheme.body(
                                    size: 15,
                                    weight: FontWeight.w700,
                                    color: c.headline,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: accents[i].withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  _stages[i].$2,
                                  style: AppTheme.body(
                                    size: 11,
                                    weight: FontWeight.w700,
                                    color: c.isDark
                                        ? accents[i]
                                        : Color.lerp(
                                            accents[i],
                                            Colors.black,
                                            0.25,
                                          )!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _stages[i].$3,
                            style: AppTheme.body(
                              size: 13,
                              color: c.onSurfaceVariant,
                            ).copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/brand_top_bar.dart';
import '../widgets/contact_card.dart';
import 'about_screen.dart' show SectionTitle;

/// One question and its answer.
typedef Faq = ({String question, String answer});

/// Questions grouped under a heading.
typedef FaqGroup = ({IconData icon, String title, List<Faq> faqs});

const List<FaqGroup> faqGroups = [
  (
    icon: Icons.auto_awesome_outlined,
    title: 'Getting Started',
    faqs: [
      (
        question: 'What is Qissora?',
        answer:
            'Qissora is the audio story app of Imaan & Akhlaq. Children '
            'listen to stories of the Prophets and to story series about '
            'values such as honesty, kindness, fairness, gratitude, patience '
            'and respect, narrated in English and Urdu.',
      ),
      (
        question: 'Which ages are the stories for?',
        answer:
            'The stories are written for children aged 5 to 13, and are '
            'lovely for the whole family to listen to together.',
      ),
      (
        question: 'How do I switch between English and Urdu?',
        answer:
            'Use the English / اردو switch at the top of the Home tab. The '
            'Home and Library tabs then show the stories in that language.',
      ),
    ],
  ),
  (
    icon: Icons.headphones_outlined,
    title: 'Listening',
    faqs: [
      (
        question: 'Do I need the internet to listen?',
        answer:
            'Only the first time a story plays. It is then kept on your '
            'phone, so it plays again without the internet and uses no more '
            'data.',
      ),
      (
        question: 'Will a story keep playing with the screen off?',
        answer:
            'Yes. Stories keep playing when the phone is locked or you '
            'switch apps, and you can pause or skip from the lock screen and '
            'the notification.',
      ),
      (
        question: 'Can my child read along?',
        answer:
            'Yes. The player shows the words of the story as they are '
            'spoken, and "Read the full story" opens the whole text.',
      ),
      (
        question: 'How does the sleep timer work?',
        answer:
            'In the player, tap Timer and choose how long to listen. When '
            'time is up the story fades out gently, which makes it perfect '
            'for bedtime.',
      ),
      (
        question: 'How do I keep my favourite stories?',
        answer:
            'In the player, tap Favorite or Save. Those stories then appear '
            'in the Library tab, ready to play again.',
      ),
    ],
  ),
  (
    icon: Icons.family_restroom_outlined,
    title: 'For Parents',
    faqs: [
      (
        question: 'What is in the Parents area?',
        answer:
            'A PIN-protected space where you can see how many stories your '
            "child has listened to and finished, set your child's name, "
            'manage favourites and saved stories, turn on night mode and '
            'reset listening history.',
      ),
      (
        question: 'How do I change the Parents PIN?',
        answer:
            'Open the Parents tab, enter the PIN, and tap "Change Parents '
            'PIN". We recommend choosing your own PIN the first time you '
            'open it.',
      ),
      (
        question: "Is my child's information safe?",
        answer:
            'Yes. Qissora has no accounts, no ads and no tracking. Everything '
            'the app remembers, like favourites and progress, stays on your '
            'phone.',
      ),
    ],
  ),
];

/// Frequently asked questions, each a card that opens to show its answer.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const BrandTopBar(title: 'FAQs'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                const _FaqHero(),
                for (final group in faqGroups) ...[
                  const SizedBox(height: 28),
                  SectionTitle(icon: group.icon, title: group.title),
                  const SizedBox(height: 12),
                  for (final faq in group.faqs) ...[
                    FaqCard(faq: faq),
                    const SizedBox(height: 10),
                  ],
                ],
                const SizedBox(height: 18),
                const ContactCard(
                  title: 'Still have a question?',
                  message:
                      'Message the Imaan & Akhlaq team on WhatsApp and '
                      'we will get back to you.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqHero extends StatelessWidget {
  const _FaqHero();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Day brand colours in both themes, so the white text keeps its
          // contrast in night mode.
          colors: [AppColors.light.secondaryDeep, AppColors.light.primary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: c.isDark ? 0.2 : 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?',
                  style: AppTheme.headline(size: 24, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Answers to the questions parents ask us most. Tap a '
                  'question to see its answer.',
                  style: AppTheme.body(
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ).copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.question_answer_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

/// A question that opens in place to show its answer.
class FaqCard extends StatefulWidget {
  final Faq faq;

  const FaqCard({super.key, required this.faq});

  @override
  State<FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: _open ? c.surfaceLow : c.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _open
              ? c.primary.withValues(alpha: 0.45)
              : c.outlineVariant.withValues(alpha: c.isDark ? 0.5 : 0.15),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _open ? c.primary : c.primaryFixed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Q',
                        style: AppTheme.headline(
                          size: 15,
                          color: _open ? Colors.white : c.primaryDeep,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.faq.question,
                        style: AppTheme.body(
                          size: 15,
                          weight: FontWeight.w600,
                          color: c.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _open ? c.primaryDeep : c.outline,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _open
                      ? Padding(
                          padding: const EdgeInsets.only(left: 44, top: 10),
                          child: Text(
                            widget.faq.answer,
                            style: AppTheme.body(
                              size: 14,
                              color: c.onSurfaceVariant,
                            ).copyWith(height: 1.55),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

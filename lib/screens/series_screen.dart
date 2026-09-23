import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/series.dart';
import '../models/series_meet.dart';
import '../models/story.dart';
import '../models/story_category.dart';
import '../services/audio_player_service.dart';
import '../services/premium_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/text_direction.dart';
import '../widgets/mini_player.dart';
import '../widgets/paywall_sheet.dart';
import '../widgets/story_tile.dart';

void openSeries(BuildContext context, Series series) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => SeriesScreen(series: series)));
}

/// Where "Play" picks up: a track left part-way through, then the first
/// episode not yet finished, and back to the start once everything is done.
Story resumeTrackOf(Series series) {
  if (series.tracks.every((t) => StorageService.getProgress(t.id) == null)) {
    return series.tracks.first;
  }
  for (final track in series.tracks) {
    if (StorageService.getProgress(track.id)?.isResumable ?? false) {
      return track;
    }
  }
  for (final episode in series.episodes) {
    if (!(StorageService.getProgress(episode.id)?.completed ?? false)) {
      return episode;
    }
  }
  return series.tracks.first;
}

/// The playlist for one series: its cover, a play button, its written
/// introduction and every episode in order.
class SeriesScreen extends StatelessWidget {
  final Series series;
  const SeriesScreen({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: Text(series.category.label)),
      bottomNavigationBar: const SafeArea(child: MiniPlayer()),
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder(
          valueListenable: StorageService.progressListenable(),
          builder: (context, _, __) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _Header(series: series),
              const SizedBox(height: 24),
              if (series.welcome case final welcome?) ...[
                _WelcomeCard(series: series, welcome: welcome),
                const SizedBox(height: 20),
              ],
              if (!context.watch<PremiumService>().isPremium) ...[
                const _PremiumBanner(),
                const SizedBox(height: 20),
              ],
              _ListLabel(series.episodeCountLabel),
              for (final episode in series.episodes)
                StoryTile(
                  story: episode,
                  onTap: () => openStory(context, episode),
                  onPlay: () => togglePlayFor(context, episode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Series series;
  const _Header({required this.series});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final seconds = series.tracks.fold<int>(
      0,
      (sum, t) =>
          sum + (t.captions.isEmpty ? 0 : t.captions.last.end.inSeconds),
    );
    final minutes = (seconds / 60).round();

    return Column(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              series.coverAsset,
              width: 220,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          series.title,
          textDirection: textDirectionOf(series.title),
          textAlign: TextAlign.center,
          style: AppTheme.headline(size: 26, color: c.headline),
        ),
        const SizedBox(height: 6),
        Text(
          series.description,
          textDirection: textDirectionOf(series.description),
          textAlign: TextAlign.center,
          style: AppTheme.body(size: 14, color: c.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        Text(
          '${series.language.label} • ${series.episodeCountLabel} • '
          '$minutes min',
          style: AppTheme.body(
            size: 13,
            weight: FontWeight.w600,
            color: c.secondaryDeep,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<AudioPlayerService>(
          builder: (context, player, _) {
            final current = player.currentStory;
            final playingHere =
                current != null &&
                series.tracks.any((t) => t.id == current.id) &&
                player.isPlaying;
            return FilledButton.icon(
              onPressed: () => playingHere
                  ? player.pause()
                  : openStory(context, resumeTrackOf(series)),
              icon: Icon(playingHere ? Icons.pause : Icons.play_arrow),
              label: Text(playingHere ? 'Pause' : 'Play'),
            );
          },
        ),
      ],
    );
  }
}

/// The series introduction, in place of the old spoken trailer.
/// The spoken welcome at the top of a series: one tap, and it plays for
/// everyone, Premium or not.
class _WelcomeCard extends StatelessWidget {
  final Series series;
  final MeetTheSeries welcome;
  const _WelcomeCard({required this.series, required this.welcome});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final urdu = series.language == StoryLanguage.urdu;
    final title = urdu ? 'سلسلے کا تعارف' : 'Meet the series';
    final minutes = (welcome.length.inSeconds / 60).ceil();
    final blurb = urdu
        ? '$minutes منٹ میں جانیے اس سلسلے میں کیا ہے'
        : 'What this series is about, in $minutes minute'
              '${minutes == 1 ? '' : 's'}.';

    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final isCurrent = player.currentStory?.id == welcome.track.id;
        final showPause = isCurrent && player.isPlaying;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => togglePlayFor(context, welcome.track),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrent ? c.surfaceHigh : c.surfaceLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCurrent
                      ? c.secondary.withValues(alpha: 0.5)
                      : c.outlineVariant.withValues(
                          alpha: c.isDark ? 0.5 : 0.15,
                        ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      showPause ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: urdu
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          textDirection: textDirectionOf(title),
                          style: AppTheme.headline(size: 17, color: c.headline),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          blurb,
                          textDirection: textDirectionOf(blurb),
                          style: AppTheme.body(
                            size: 13,
                            color: c.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tells a free listener that episode 1 is a preview and the rest is Premium.
class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.secondaryFixed,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showPaywall(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.surfaceLowest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.workspace_premium, color: c.secondaryDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Episode 1 is a free preview',
                      style: AppTheme.body(
                        size: 14,
                        weight: FontWeight.w700,
                        color: c.onSurface,
                      ),
                    ),
                    Text(
                      'Unlock every episode with Premium',
                      style: AppTheme.body(size: 13, color: c.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.secondaryDeep),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListLabel extends StatelessWidget {
  final String text;
  const _ListLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: AppTheme.headline(size: 18, color: c.headline)),
    );
  }
}

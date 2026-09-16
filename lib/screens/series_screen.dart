import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/series.dart';
import '../models/story.dart';
import '../models/story_category.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/story_tile.dart';

void openSeries(BuildContext context, Series series) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => SeriesScreen(series: series)));
}

/// Where "Play" picks up: the trailer on a series never played, then a track
/// left part-way through, then the first episode not yet finished, and back
/// to the start once everything is done.
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

/// The playlist for one series: its cover, a play button, the trailer and
/// every episode in order.
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
              if (series.trailer case final trailer?) ...[
                const _ListLabel('Trailer'),
                StoryTile(
                  story: trailer,
                  onTap: () => openStory(context, trailer),
                  onPlay: () => togglePlayFor(context, trailer),
                ),
                const SizedBox(height: 12),
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
          textAlign: TextAlign.center,
          style: AppTheme.headline(size: 26, color: c.headline),
        ),
        const SizedBox(height: 6),
        Text(
          series.description,
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

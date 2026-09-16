import 'package:flutter/material.dart';

import '../models/series.dart';
import '../screens/series_screen.dart';
import '../theme/app_theme.dart';

/// A series thumbnail: cover, title, and how many episodes it holds. Tapping
/// opens the series playlist.
class SeriesCard extends StatelessWidget {
  final Series series;
  final double width;

  const SeriesCard({super.key, required this.series, this.width = 150});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: '${series.title}, ${series.episodeCountLabel}',
      child: GestureDetector(
        onTap: () => openSeries(context, series),
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  series.coverAsset,
                  width: width,
                  height: width,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                series.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(
                  size: 14,
                  weight: FontWeight.w700,
                  color: c.onSurface,
                ),
              ),
              Text(
                '${series.episodeCountLabel} • ${series.language.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(size: 12, color: c.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Thin progress indicator shown under story tiles.
///
/// Renders nothing when the story has never been played. Shows a full bar
/// with a check icon when completed, otherwise the fraction listened.
class StoryProgressBar extends StatelessWidget {
  final String storyId;
  final double height;

  const StoryProgressBar({super.key, required this.storyId, this.height = 4});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: StorageService.progressListenable(),
      builder: (context, _, __) {
        final p = StorageService.getProgress(storyId);
        if (p == null || (p.fraction == 0 && !p.completed)) {
          return const SizedBox.shrink();
        }
        final c = context.colors;
        final value = p.completed ? 1.0 : p.fraction;
        return Semantics(
          label: p.completed
              ? 'Finished'
              : '${(value * 100).round()} percent listened',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height),
            child: LinearProgressIndicator(
              value: value,
              minHeight: height,
              backgroundColor: c.surfaceVariant,
              color: p.completed ? c.success : c.secondary,
            ),
          ),
        );
      },
    );
  }
}

/// Small pill label like "Resume · 02:15" or "✓ Finished".
class StoryProgressLabel extends StatelessWidget {
  final String storyId;
  final TextStyle style;

  const StoryProgressLabel({
    super.key,
    required this.storyId,
    required this.style,
  });

  static String fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final p = StorageService.getProgress(storyId);
    final c = context.colors;
    if (p == null) return const SizedBox.shrink();
    if (p.completed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 13, color: c.success),
          const SizedBox(width: 3),
          Text('Finished', style: style.copyWith(color: c.success)),
        ],
      );
    }
    if (p.isResumable) {
      return Text(
        'Resume ${fmt(p.position)}',
        style: style.copyWith(color: c.secondaryDeep),
      );
    }
    return const SizedBox.shrink();
  }
}

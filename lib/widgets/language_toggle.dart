import 'package:flutter/material.dart';

import '../models/series.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// English / اردو switch for which series the child browses. The choice is
/// saved, so the app opens in the same language next time.
///
/// It rides in the home screen's top bar rather than taking a row of its own
/// above the featured card: both languages stay one tap away, and the shelf
/// beneath starts that much higher up the screen.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ValueListenableBuilder(
      valueListenable: StorageService.languageListenable(),
      builder: (context, _, __) => SegmentedButton<StoryLanguage>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          textStyle: AppTheme.body(
            size: 13,
            weight: FontWeight.w700,
            color: c.headline,
          ),
        ),
        segments: [
          for (final language in StoryLanguage.values)
            ButtonSegment(value: language, label: Text(language.label)),
        ],
        selected: {StorageService.getLanguage()},
        onSelectionChanged: (picked) =>
            StorageService.setLanguage(picked.single),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/series.dart';
import '../services/storage_service.dart';

/// English / اردو switch for which series the child browses. The choice is
/// saved, so the app opens in the same language next time.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: StorageService.languageListenable(),
      builder: (context, _, __) => SegmentedButton<StoryLanguage>(
        showSelectedIcon: false,
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

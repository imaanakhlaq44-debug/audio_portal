import 'package:flutter/material.dart';

enum StoryCategory { prophets, moral }

extension StoryCategoryX on StoryCategory {
  String get label {
    switch (this) {
      case StoryCategory.prophets:
        return 'Prophets';
      case StoryCategory.moral:
        return 'Moral Stories';
    }
  }

  IconData get icon {
    switch (this) {
      case StoryCategory.prophets:
        return Icons.auto_awesome;
      case StoryCategory.moral:
        return Icons.favorite;
    }
  }
}

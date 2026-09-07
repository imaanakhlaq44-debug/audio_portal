import 'package:flutter/material.dart';

enum StoryCategory { prophets, animals, nature, bedtime, moral }

extension StoryCategoryX on StoryCategory {
  String get label {
    switch (this) {
      case StoryCategory.prophets:
        return 'Prophets';
      case StoryCategory.animals:
        return 'Animals';
      case StoryCategory.nature:
        return 'Nature';
      case StoryCategory.bedtime:
        return 'Bedtime';
      case StoryCategory.moral:
        return 'Moral Stories';
    }
  }

  IconData get icon {
    switch (this) {
      case StoryCategory.prophets:
        return Icons.auto_awesome;
      case StoryCategory.animals:
        return Icons.pets;
      case StoryCategory.nature:
        return Icons.eco;
      case StoryCategory.bedtime:
        return Icons.bedtime;
      case StoryCategory.moral:
        return Icons.favorite;
    }
  }
}

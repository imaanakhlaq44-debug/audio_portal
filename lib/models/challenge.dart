import 'package:flutter/foundation.dart';

/// The small thing to go and do, that an episode closes on.
///
/// Every episode has one. It is read out at the end of the narration in most
/// series, and the Parents area shows it again afterwards so a parent knows
/// what to try with their child that day — the words alone, with no audio
/// behind them, which is why a few of these exist for episodes whose
/// recording never said them aloud.
@immutable
class Challenge {
  /// A few words naming it, e.g. "Leave a Good Footprint".
  final String title;

  /// The challenge itself, spoken to the child.
  final String mission;

  /// The question to ask afterwards. Only the Kindness scripts have these.
  final String reflection;

  /// The harder version, for a child who wants more.
  final String levelUp;

  const Challenge({
    required this.title,
    required this.mission,
    this.reflection = '',
    this.levelUp = '',
  });

  bool get hasReflection => reflection.isNotEmpty;
  bool get hasLevelUp => levelUp.isNotEmpty;
}

import 'package:flutter/widgets.dart';

final _arabicScript = RegExp('[؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]');
final _latin = RegExp('[A-Za-z]');

/// Right-to-left for text written in Urdu script, left-to-right otherwise.
///
/// The app's chrome is English, so the ambient direction is LTR; an Urdu
/// title or caption laid out that way puts "؟" and "۔" at the wrong end and
/// hugs the wrong edge. Decided by whichever script appears first.
TextDirection textDirectionOf(String text) {
  final arabic = _arabicScript.firstMatch(text)?.start;
  if (arabic == null) return TextDirection.ltr;
  final latin = _latin.firstMatch(text)?.start;
  return latin != null && latin < arabic
      ? TextDirection.ltr
      : TextDirection.rtl;
}

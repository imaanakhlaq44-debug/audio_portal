// Cuts a narrated series into episodes and generates its Story entries, with
// read-along captions aligned to what is actually spoken.
//
// Input is the narration script plus a timestamped transcript of the full
// master recording, made once with ffmpeg's whisper filter:
//
//   ffmpeg -i master.wav -af "aresample=16000,whisper=model=ggml-small.bin:
//     language=en:queue=20:format=srt:destination=series.srt" -f null -
//
// The script's words are matched against the transcript's words in order, so
// every script line gets the time it was really spoken. Episodes are cut just
// before their spoken "Episode N" title, which keeps each episode's closing
// "Challenge of the Day" with the episode it belongs to.
//
// Usage, from the repo root:
//   dart run tools/gen_series.dart tools/series/fairness_en.json [--cut]
//       [--opus=16] [--reuse-cuts]
//
// --cut also writes the episode audio: 48 kbps mp3, or Opus at the given
// kbps with --opus. --reuse-cuts takes episode boundaries from the
// <config>.cuts.json written by an earlier run instead of listening again.
// ffmpeg is taken from PATH or the FFMPEG environment variable; checking
// cuts by ear needs WHISPER_MODEL.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Silence left before an episode's first words and after its last.
const _edgePadding = 0.25;

void main(List<String> args) async {
  final configPath = args.firstWhere(
    (a) => !a.startsWith('--'),
    orElse: () {
      stderr.writeln(
        'usage: dart run tools/gen_series.dart <config.json> [--cut]',
      );
      exit(64);
    },
  );
  final cfg =
      jsonDecode(File(configPath).readAsStringSync()) as Map<String, dynamic>;
  final trailerFile = cfg['trailer'] as String?;
  final (intro, parts) = _splitScript(cfg);

  // Episode files are named from their titles unless the config lists them.
  final episodeFiles =
      (cfg['episodes'] as List?)?.cast<String>() ??
      [
        for (var i = 0; i < parts.length; i++)
          // Urdu titles have no Latin letters to slug; the number alone will do.
          '${[(i + 1).toString().padLeft(2, '0'), if (_slug(parts[i].title).isNotEmpty) _slug(parts[i].title)].join('_')}.mp3',
      ];
  if (parts.length != episodeFiles.length) {
    _fail(
      'script has ${parts.length} episodes but the config lists '
      '${episodeFiles.length} files',
    );
  }

  // The spoken intro (series title, moral, list of episodes) becomes its own
  // trailer track when the config names one; otherwise it opens episode 1.
  final hasTrailer = trailerFile != null && intro.isNotEmpty;
  if (!hasTrailer) parts.first.lines.insertAll(0, intro);
  final episodes = [
    if (hasTrailer) _Episode('Trailer')..lines.addAll(intro),
    ...parts,
  ];
  // --opus=16 writes Opus at that many kbps (.ogg); the default is 48 kbps mp3.
  final opusKbps = args
      .where((a) => a.startsWith('--opus='))
      .map((a) => int.parse(a.substring('--opus='.length)))
      .firstOrNull;
  final ext = opusKbps == null ? 'mp3' : 'ogg';
  final files = [
    for (final f in [if (hasTrailer) trailerFile, ...episodeFiles])
      f.replaceFirst(RegExp(r'\.\w+$'), '.$ext'),
  ];

  final spoken = _readSrt(cfg['transcript'] as String);
  final lines = [for (final e in episodes) ...e.lines];
  _align(lines, spoken);

  // Where each episode starts is the slow part (it is heard, not computed),
  // so it is kept next to the config. --reuse-cuts skips straight to it,
  // which makes re-encoding the series in another format a few minutes' work.
  final cutsFile = File(
    configPath.replaceFirst(RegExp(r'\.json$'), '.cuts.json'),
  );
  final ffmpeg = Platform.environment['FFMPEG'] ?? 'ffmpeg';
  final List<(double, double)> bounds;
  if (args.contains('--reuse-cuts') && cutsFile.existsSync()) {
    bounds = [
      for (final b in jsonDecode(cutsFile.readAsStringSync()) as List)
        ((b[0] as num).toDouble(), (b[1] as num).toDouble()),
    ];
    if (bounds.length != episodes.length) {
      _fail(
        '${cutsFile.path} has ${bounds.length} cuts for ${episodes.length} tracks',
      );
    }
  } else {
    final total = spoken.last.end;
    final pauses = await _silences(ffmpeg, cfg['master'] as String);
    bounds = await _confirmByListening(
      ffmpeg,
      cfg,
      episodes,
      _snapToSilence(_episodeBounds(episodes, total), pauses),
      pauses,
    );
    cutsFile.writeAsStringSync(
      '${jsonEncode([
        for (final (s, t) in bounds) [double.parse(s.toStringAsFixed(3)), double.parse(t.toStringAsFixed(3))],
      ])}\n',
    );
  }
  _report(episodes, lines, bounds);

  File(cfg['output'] as String)
    ..createSync(recursive: true)
    ..writeAsStringSync(
      _dart(cfg, configPath, episodes, files, bounds, hasTrailer: hasTrailer),
    );
  stdout.writeln('wrote ${cfg['output']}');

  if (args.contains('--cut')) {
    await _cut(ffmpeg, cfg, files, bounds, opusKbps: opusKbps);
  }
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}

// ---------------------------------------------------------------------------
// Script

class _Line {
  _Line(this.text) : words = _tokens(text);
  final String text;
  final List<String> words;
  double? start;
  double? end;
}

class _Episode {
  _Episode(this.title);
  String title;
  final lines = <_Line>[];
}

/// Episode numbers written as words in the scripts ("Chapter Three",
/// "قسط سوم").
const _ordinals = {
  'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, //
  'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
  'اول': 1, 'دوم': 2, 'سوم': 3, 'چہارم': 4, 'پنجم': 5, //
  'ششم': 6, 'ہفتم': 7, 'ہشتم': 8, 'نہم': 9, 'دہم': 10,
  // "قسط 1" is written as a digit but read aloud as "قسط ایک".
  'ایک': 1, 'دو': 2, 'تین': 3, 'چار': 4, 'پانچ': 5, //
  'چھ': 6, 'سات': 7, 'آٹھ': 8, 'نو': 9, 'دس': 10,
};

/// Splits the script at each episode marker, returning the spoken intro that
/// comes before the first marker separately. Emotion tags such as `[warm]`
/// are stage directions and are not spoken.
(List<_Line>, List<_Episode>) _splitScript(Map<String, dynamic> cfg) {
  final marker = RegExp(cfg['episodeMarker'] as String);
  final tag = RegExp(r'^\[[^\]]+\]$');
  final raw = File(
    cfg['script'] as String,
  ).readAsLinesSync().skip((cfg['skipLeadingLines'] as int?) ?? 0);

  final intro = <_Line>[];
  final episodes = <_Episode>[];

  // Urdu scripts put the emotion tag at the start of a spoken line
  // ("[warm] ...") rather than on a line of its own.
  final inlineTag = RegExp(r'\[[^\]]+\]\s*');
  for (final text in raw.map((l) => l.replaceAll(inlineTag, '').trim())) {
    if (text.isEmpty || tag.hasMatch(text)) continue;

    final m = marker.firstMatch(text);
    if (m != null) {
      final raw = m.group(1)!.trim();
      final n = int.tryParse(raw) ?? _ordinals[raw.toLowerCase()];
      if (n == 1 && episodes.isNotEmpty) {
        // The numbering started over, so what came before was the contents
        // list at the top of the script: part of the spoken intro.
        intro.addAll([for (final e in episodes) ...e.lines]);
        episodes.clear();
      } else if (n != episodes.length + 1) {
        _fail('expected episode ${episodes.length + 1}, found "$text"');
      }
      // Some scripts put the title on the line after "EPISODE 1".
      final title = m.groupCount >= 2 ? m.group(2)?.trim() : null;
      episodes.add(_Episode(title ?? ''));
    } else if (episodes.isNotEmpty && episodes.last.title.isEmpty) {
      episodes.last.title = text;
    }

    // Urdu scripts put a whole paragraph on one line; a caption that long
    // fills the screen, so those are read out a sentence at a time.
    final pieces = m == null && cfg['splitSentences'] == true
        ? text.split(RegExp(r'(?<=[۔؟])\s+'))
        : [text];
    for (final piece in pieces) {
      final line = _Line(piece);
      if (line.words.isEmpty) continue;
      (episodes.isEmpty ? intro : episodes.last.lines).add(line);
    }
  }
  return (intro, episodes);
}

/// "Amanpur's Promise" -> "amanpurs_promise".
String _slug(String title) => title
    .toLowerCase()
    .replaceAll(RegExp(r"['’]"), '')
    .split(RegExp(r'[^a-z0-9]+'))
    .where((w) => w.isNotEmpty)
    .join('_');

List<String> _tokens(String text) => text
    .toLowerCase()
    .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
    .where((w) => w.isNotEmpty)
    .toList();

// ---------------------------------------------------------------------------
// Transcript

class _Word {
  _Word(this.word, this.start, this.end);
  final String word;
  final double start;
  final double end;
}

/// Reads an SRT file into single words. Whisper only times whole segments, so
/// each word gets a slice of its segment proportional to its length.
List<_Word> _readSrt(String path) {
  final time = RegExp(
    r'(\d+):(\d+):(\d+)[,.](\d+)\s*-->\s*(\d+):(\d+):(\d+)[,.](\d+)',
  );
  double secs(Match m, int i) =>
      int.parse(m.group(i)!) * 3600 +
      int.parse(m.group(i + 1)!) * 60 +
      int.parse(m.group(i + 2)!) +
      int.parse(m.group(i + 3)!) / 1000;

  final words = <_Word>[];
  final lines = File(path).readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final m = time.firstMatch(lines[i]);
    if (m == null) continue;
    final start = secs(m, 1);
    final end = secs(m, 5);

    final text = StringBuffer();
    while (i + 1 < lines.length && lines[i + 1].trim().isNotEmpty) {
      text.write(' ${lines[++i]}');
    }
    final tokens = _tokens(text.toString());
    final chars = tokens.fold<int>(0, (s, w) => s + w.length);
    var t = start;
    for (final w in tokens) {
      final len = (end - start) * w.length / chars;
      words.add(_Word(w, t, t + len));
      t += len;
    }
  }
  if (words.isEmpty) _fail('no words in $path');
  return words;
}

// ---------------------------------------------------------------------------
// Alignment

/// Matches the script's words to the transcript's words. Whisper misspells
/// names and writes numbers as digits, so a plain left-to-right walk loses its
/// place and never finds it again. Instead, runs of four words that occur
/// exactly once in both texts are fixed anchors; the longest chain of them
/// that runs forward in both is kept, and only the short stretches between
/// anchors are matched word by word.
void _align(List<_Line> lines, List<_Word> spoken) {
  final script = <(int line, String word)>[
    for (var l = 0; l < lines.length; l++)
      for (final w in lines[l].words) (l, w),
  ];
  final s = [for (final x in script) x.$2];
  final t = [for (final w in spoken) w.word];
  final matched = List<int?>.filled(s.length, null);

  const gram = 4;
  Map<String, List<int>> grams(List<String> words) {
    final map = <String, List<int>>{};
    for (var i = 0; i + gram <= words.length; i++) {
      (map[words.sublist(i, i + gram).join(' ')] ??= []).add(i);
    }
    return map;
  }

  final sGrams = grams(s);
  final tGrams = grams(t);
  final anchors = <(int, int)>[
    for (final e in sGrams.entries)
      if (e.value.length == 1 && tGrams[e.key]?.length == 1)
        (e.value.single, tGrams[e.key]!.single),
  ]..sort((a, b) => a.$1.compareTo(b.$1));

  var last = -1;
  for (final (i, k) in _increasingChain(anchors)) {
    for (var d = 0; d < gram; d++) {
      if (k + d > last && matched[i + d] == null) {
        matched[i + d] = k + d;
        last = k + d;
      }
    }
  }

  // Fill each unmatched stretch from the transcript words between the
  // anchors on either side of it.
  for (var a = 0; a < s.length; a++) {
    if (matched[a] != null) continue;
    var b = a;
    while (b < s.length && matched[b] == null) {
      b++;
    }
    final from = a == 0 ? 0 : matched[a - 1]! + 1;
    final to = b == s.length ? t.length : matched[b]!;
    if (to > from && (b - a) * (to - from) <= 400000) {
      _matchStretch(s, a, b, t, from, to, matched);
    }
    a = b;
  }

  for (var i = 0; i < script.length; i++) {
    final k = matched[i];
    if (k == null) continue;
    final line = lines[script[i].$1];
    line.start ??= spoken[k].start;
    line.end = spoken[k].end;
  }

  // A line with no matched word at all sits between its neighbours, sharing
  // the gap by word count.
  for (var l = 0; l < lines.length; l++) {
    if (lines[l].start != null) continue;
    var r = l;
    while (r < lines.length && lines[r].start == null) {
      r++;
    }
    final from = l == 0 ? 0.0 : lines[l - 1].end!;
    final to = r < lines.length ? lines[r].start! : spoken.last.end;
    final words = [
      for (var i = l; i < r; i++) lines[i].words.length,
    ].fold<int>(0, (a, b) => a + b);
    var t = from;
    for (var i = l; i < r; i++) {
      lines[i].start = t;
      t += (to - from) * lines[i].words.length / words;
      lines[i].end = t;
    }
    l = r - 1;
  }

  final hit = matched.where((m) => m != null).length;
  stdout.writeln(
    'aligned ${(100 * hit / script.length).toStringAsFixed(1)}% of '
    '${script.length} script words',
  );
}

/// The longest run of anchors whose transcript positions keep increasing
/// (anchors arrive sorted by script position).
List<(int, int)> _increasingChain(List<(int, int)> anchors) {
  final tails = <int>[]; // index into anchors of the smallest tail per length
  final prev = List<int>.filled(anchors.length, -1);
  for (var i = 0; i < anchors.length; i++) {
    var lo = 0;
    var hi = tails.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (anchors[tails[mid]].$2 < anchors[i].$2) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    if (lo > 0) prev[i] = tails[lo - 1];
    if (lo == tails.length) {
      tails.add(i);
    } else {
      tails[lo] = i;
    }
  }
  final chain = <(int, int)>[];
  for (var i = tails.isEmpty ? -1 : tails.last; i >= 0; i = prev[i]) {
    chain.add(anchors[i]);
  }
  return chain.reversed.toList();
}

/// Longest common subsequence of script words [a, b) and transcript words
/// [from, to), recorded into [matched].
void _matchStretch(
  List<String> s,
  int a,
  int b,
  List<String> t,
  int from,
  int to,
  List<int?> matched,
) {
  final rows = b - a;
  final cols = to - from;
  final dp = List.generate(rows + 1, (_) => List<int>.filled(cols + 1, 0));
  for (var i = rows - 1; i >= 0; i--) {
    for (var j = cols - 1; j >= 0; j--) {
      dp[i][j] = s[a + i] == t[from + j]
          ? dp[i + 1][j + 1] + 1
          : max(dp[i + 1][j], dp[i][j + 1]);
    }
  }
  var i = 0;
  var j = 0;
  while (i < rows && j < cols) {
    if (s[a + i] == t[from + j]) {
      matched[a + i] = from + j;
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      i++;
    } else {
      j++;
    }
  }
}

// ---------------------------------------------------------------------------
// Episodes

/// Each episode after the first starts in the pause before its spoken title.
List<(double, double)> _episodeBounds(List<_Episode> episodes, double total) {
  final starts = <double>[0];
  for (var e = 1; e < episodes.length; e++) {
    // An episode's first line is its "Episode N: ..." marker.
    final title = episodes[e].lines.first;
    final prev = episodes[e - 1].lines.last;
    final gapStart = prev.end!;
    final gapEnd = title.start!;
    starts.add(
      gapEnd > gapStart
          ? max(gapStart, gapEnd - _edgePadding)
          : gapEnd - _edgePadding,
    );
  }
  return [
    for (var e = 0; e < episodes.length; e++)
      (starts[e], e + 1 < episodes.length ? starts[e + 1] : total),
  ];
}

void _report(
  List<_Episode> episodes,
  List<_Line> lines,
  List<(double, double)> bounds,
) {
  for (var e = 0; e < episodes.length; e++) {
    final (s, t) = bounds[e];
    stdout.writeln(
      '  ${(e + 1).toString().padLeft(2)}  '
      '${_clock(s)} - ${_clock(t)}  (${((t - s) / 60).toStringAsFixed(2)} min)'
      '  ${episodes[e].title}',
    );
  }
}

String _clock(double s) =>
    '${(s ~/ 60).toString().padLeft(2, '0')}:'
    '${(s % 60).toStringAsFixed(1).padLeft(4, '0')}';

String _dart(
  Map<String, dynamic> cfg,
  String configPath,
  List<_Episode> episodes,
  List<String> files,
  List<(double, double)> bounds, {
  required bool hasTrailer,
}) {
  final series = cfg['series'] as String;
  final urdu = cfg['language'] == 'urdu';
  final count = episodes.length - (hasTrailer ? 1 : 0);
  final out = StringBuffer()
    ..writeln('// GENERATED by tools/gen_series.dart from $configPath.')
    ..writeln('// Do not edit by hand: change the config or script and rerun.')
    ..writeln('//')
    ..writeln('// Caption times come from aligning the script to a whisper')
    ..writeln('// transcript of the recording.')
    ..writeln()
    ..writeln("import '../series.dart';")
    ..writeln("import '../story.dart';")
    ..writeln("import '../story_category.dart';")
    ..writeln()
    ..writeln('const Series ${cfg['variable']} = Series(')
    ..writeln("  id: '${cfg['id']}',")
    ..writeln('  title: ${_str(series)},')
    ..writeln('  language: StoryLanguage.${cfg['language']},')
    ..writeln('  category: StoryCategory.${cfg['category']},')
    ..writeln('  coverAsset: ${_str(cfg['cover'] as String)},')
    ..writeln(
      '  description: ${_str(urdu ? '${cfg['moral']} پر $count اقساط کی کہانی' : 'A $count-part story about ${cfg['moral']}.')},',
    );

  for (var e = 0; e < episodes.length; e++) {
    final ep = episodes[e];
    final (epStart, epEnd) = bounds[e];
    final isTrailer = hasTrailer && e == 0;
    final n = hasTrailer ? e : e + 1;

    if (isTrailer) out.write('  trailer: ');
    if (e == (hasTrailer ? 1 : 0)) out.writeln('  episodes: [');
    out
      ..writeln('  Story(')
      ..writeln("    id: '${cfg['id']}_${n.toString().padLeft(2, '0')}',")
      ..writeln(
        '    title: ${_str(isTrailer ? '${urdu ? 'ٹریلر' : 'Trailer'} · $series' : '${urdu ? 'قسط' : 'Ep'} $n · ${ep.title}')},',
      )
      ..writeln('    narrator: ${_str(cfg['narrator'] as String)},')
      ..writeln('    coverAsset: ${_str(cfg['cover'] as String)},')
      ..writeln('    audioAsset: ${_str('${cfg['audioDir']}/${files[e]}')},')
      ..writeln('    category: StoryCategory.${cfg['category']},')
      ..writeln(
        '    description: ${_str(isTrailer ? (urdu ? '$series کا تعارف' : 'Meet the story: $series in under a minute.') : (urdu ? '$series — قسط $n از $count' : '$series — episode $n of $count.'))},',
      )
      ..writeln('    captions: [');

    var prevEndMs = 0;
    for (var i = 0; i < ep.lines.length; i++) {
      final line = ep.lines[i];
      final nextStart = i + 1 < ep.lines.length
          ? ep.lines[i + 1].start!
          : epEnd;
      final startMs = max(prevEndMs, ((line.start! - epStart) * 1000).round());
      final endMs = max(
        startMs + 1,
        ((min(line.end!, nextStart) - epStart) * 1000).round(),
      );
      out.writeln(
        '      CaptionLine('
        'start: Duration(milliseconds: $startMs), '
        'end: Duration(milliseconds: $endMs), '
        'text: ${_str(line.text)}),',
      );
      prevEndMs = endMs;
    }

    out
      ..writeln('    ],')
      ..writeln('  ),');
  }
  out
    ..writeln('  ],')
    ..writeln(');');
  return out.toString();
}

/// Pauses in the master as (start, end) seconds: the whole file by default,
/// or just [length] seconds from [from].
Future<List<(double, double)>> _silences(
  String ffmpeg,
  String master, {
  double from = 0,
  double? length,
  double minPause = 0.3,
}) async {
  final result = await Process.run(ffmpeg, [
    '-hide_banner',
    '-nostats',
    if (from > 0) ...['-ss', from.toStringAsFixed(3)],
    if (length != null) ...['-t', length.toStringAsFixed(3)],
    '-i',
    master,
    '-af',
    'silencedetect=noise=-30dB:d=$minPause',
    '-f',
    'null',
    '-',
  ]);
  if (result.exitCode != 0) _fail('ffmpeg could not read $master');
  final starts = RegExp(r'silence_start: ([\d.]+)')
      .allMatches(result.stderr as String)
      .map((m) => double.parse(m.group(1)!))
      .toList();
  final ends = RegExp(r'silence_end: ([\d.]+)')
      .allMatches(result.stderr as String)
      .map((m) => double.parse(m.group(1)!))
      .toList();
  return [
    for (var i = 0; i < min(starts.length, ends.length); i++)
      (from + starts[i], from + ends[i]),
  ];
}

/// Whisper's segment times are themselves off by up to a second or so, which
/// is enough to clip the first word of an episode title. Each boundary moves
/// to the longest real pause shortly before the estimated title start; the
/// pause between episodes is the longest one around.
List<(double, double)> _snapToSilence(
  List<(double, double)> bounds,
  List<(double, double)> pauses,
) {
  final starts = <double>[0];
  for (var e = 1; e < bounds.length; e++) {
    final guess = bounds[e].$1;
    (double, double)? best;
    for (final p in pauses) {
      if (p.$2 < guess - 4 || p.$1 > guess + 2) continue;
      if (best == null || p.$2 - p.$1 > best.$2 - best.$1) best = p;
    }
    starts.add(best == null ? guess : max(best.$1, best.$2 - _edgePadding));
  }
  return [
    for (var e = 0; e < bounds.length; e++)
      (starts[e], e + 1 < bounds.length ? starts[e + 1] : bounds.last.$2),
  ];
}

/// Pause-snapping alone picks the wrong pause about a third of the time:
/// these scripts end an episode with "Next episode: X" right before
/// "Episode N: X", and both pauses look alike. So each boundary is checked
/// by ear. Starting from the nearest pause, a few seconds are transcribed
/// and the cut is accepted where the first words heard are the episode's own
/// title line.
///
/// Needs WHISPER_MODEL pointing at a whisper.cpp model file.
Future<List<(double, double)>> _confirmByListening(
  String ffmpeg,
  Map<String, dynamic> cfg,
  List<_Episode> episodes,
  List<(double, double)> bounds,
  List<(double, double)> pauses,
) async {
  final model = Platform.environment['WHISPER_MODEL'];
  if (model == null || !File(model).existsSync()) {
    _fail('set WHISPER_MODEL to a whisper.cpp model file to check the cuts');
  }
  final lang = cfg['language'] == 'urdu' ? 'ur' : 'en';
  final master = File(cfg['master'] as String).absolute.path;
  // Filter options are ':'-separated and a Windows path has a drive colon, so
  // ffmpeg runs from the model's folder and the filter only names files.
  final modelFile = File(model).absolute;
  final workDir = modelFile.parent.path;
  final modelName = modelFile.uri.pathSegments.last;
  final heardFile = File('$workDir/gen_series_heard.txt');

  Future<List<String>> hear(double at) async {
    if (heardFile.existsSync()) heardFile.deleteSync();
    final result = await Process.run(ffmpeg, [
      '-hide_banner',
      '-loglevel',
      'error',
      '-ss',
      at.toStringAsFixed(3),
      '-t',
      '6',
      '-i',
      master,
      '-af',
      'aresample=16000,whisper=model=$modelName:language=$lang'
          ':queue=6:use_gpu=false:format=text'
          ':destination=gen_series_heard.txt',
      '-f',
      'null',
      '-',
    ], workingDirectory: workDir);
    if (result.exitCode != 0) _fail('whisper failed: ${result.stderr}');
    return heardFile.existsSync()
        ? _numbered(_tokens(heardFile.readAsStringSync()))
        : [];
  }

  // "cutAt" pins an episode's start by hand, in seconds, for the rare title
  // listening gets wrong (keyed by episode number, e.g. {"2": 562.52}).
  final pinned = (cfg['cutAt'] as Map<String, dynamic>? ?? {}).map(
    (k, v) => MapEntry(int.parse(k), (v as num).toDouble()),
  );
  final hasTrailer = episodes.first.title == 'Trailer';

  final starts = <double>[0];
  for (var e = 1; e < episodes.length; e++) {
    final episodeNumber = hasTrailer ? e : e + 1;
    if (pinned[episodeNumber] case final at?) {
      starts.add(at);
      continue;
    }
    final guess = bounds[e].$1;
    final title = _numbered(episodes[e].lines.first.words);
    final want = title.take(min(2, title.length)).toList();

    List<(double, double)> nearest(List<(double, double)> from) =>
        from.where((p) => p.$2 > guess - 12 && p.$1 < guess + 12).toList()
          ..sort(
            (a, b) => (a.$2 - guess).abs().compareTo((b.$2 - guess).abs()),
          );

    final tried = <double>{};
    Future<double?> listen(List<(double, double)> candidates) async {
      for (final p in candidates) {
        final at = max(p.$1, p.$2 - _edgePadding);
        if (!tried.add((at * 10).roundToDouble())) continue;
        final heard = await hear(at);
        final hit = lang == 'ur'
            ? _heardUrduTitle(heard, episodes[e])
            // Allow one stray leading word ("So", a breath read as "Uh").
            : [0, 1].any(
                (o) =>
                    heard.length >= o + want.length &&
                    List.generate(
                      want.length,
                      (i) => heard[o + i] == want[i],
                    ).every((x) => x),
              );
        if (hit) return at;
      }
      return null;
    }

    var found = await listen(nearest(pauses).take(8).toList());
    // A narrator sometimes barely pauses before a title; look again for the
    // short pauses the full-file scan leaves out.
    found ??= await listen(
      nearest(
        await _silences(
          ffmpeg,
          cfg['master'] as String,
          from: max(0, guess - 12),
          length: 24,
          minPause: 0.1,
        ),
      ).take(12).toList(),
    );
    if (found == null) {
      stderr.writeln(
        'WARNING: could not hear "${episodes[e].lines.first.text}" near '
        '${_clock(guess)}; keeping the estimate, check this cut by ear',
      );
    }
    starts.add(found ?? guess);
  }
  if (heardFile.existsSync()) heardFile.deleteSync();

  return [
    for (var e = 0; e < episodes.length; e++)
      (starts[e], e + 1 < episodes.length ? starts[e + 1] : bounds.last.$2),
  ];
}

/// Whisper spells Urdu inconsistently: "قسط دوم" comes back as "کسٹ دوم",
/// "قسطحشتم", "واقعی آتین" or "باب پنجم اید". Letters that sound alike are
/// folded together, and the title counts as heard when one of the first two
/// words is an episode marker (قسط, باب, واقعہ) followed straight away by the
/// episode's number, or by its name one word later.
///
/// Requiring the number or that exact position matters: the Saleh and Nuh
/// scripts close episodes with "اگلی قسط: (next title)", which has the
/// marker and the name but no number, with the name right after the marker.
bool _heardUrduTitle(List<String> heard, _Episode episode) {
  final titleWords = episode.lines.first.words;
  if (titleWords.length < 2) return false;
  final n = int.tryParse(titleWords[1]) ?? _ordinals[titleWords[1]];
  if (n == null) return false;
  final numberForms = {
    n.toString(),
    for (final e in _ordinals.entries)
      if (e.value == n) _fold(e.key),
  };
  final nameWord = titleWords.length > 2
      ? titleWords[2]
      : (episode.lines.length > 1 ? episode.lines[1].words.first : null);
  final name = nameWord == null ? null : _skeleton(nameWord);
  final words = heard.map(_fold).toList();

  bool isMarker(String w) =>
      ['کس', 'باب', 'واک'].any((m) => w.startsWith(_fold(m)));
  bool isNumber(String w) =>
      numberForms.any((f) => w == f || (f.length >= 2 && w.endsWith(f)));
  bool isName(String w) {
    if (name == null || name.isEmpty) return false;
    final s = _skeleton(w);
    return s == name || (name.length >= 3 && s.startsWith(name));
  }

  for (var i = 0; i < min(2, words.length); i++) {
    final w = words[i];
    if (!isMarker(w)) continue;
    if (isNumber(w)) return true; // run together: "قسطحشتم"
    if (i + 1 < words.length && isNumber(words[i + 1])) return true;
    if (i + 2 < words.length && isName(words[i + 2])) return true;
  }
  return false;
}

/// A word with its vowel letters dropped, so "خاموش" and "خموش", or
/// "اعتماد" and "اتماد", compare equal.
String _skeleton(String word) =>
    _fold(word).replaceAll(RegExp('[اویعءہے]'), '');

String _fold(String word) {
  const alike = {
    'ق': 'ک', 'ط': 'ت', 'ٹ': 'ت', 'ص': 'س', 'ث': 'س', //
    'ذ': 'ز', 'ض': 'ز', 'ظ': 'ز', 'ح': 'ہ', 'ھ': 'ہ',
    'ۃ': 'ہ', 'ة': 'ہ', 'ي': 'ی', 'ى': 'ی', 'ئ': 'ی',
    'أ': 'ا', 'آ': 'ا', 'ؤ': 'و',
  };
  return word
      .replaceAll(RegExp('[ً-ٰٟ]'), '')
      .split('')
      .map((c) => alike[c] ?? c)
      .join();
}

/// Spelled-out numbers become digits, so "Chapter Four" matches "chapter 4".
List<String> _numbered(List<String> words) => [
  for (final w in words) _ordinals[w]?.toString() ?? w,
];

Future<void> _cut(
  String ffmpeg,
  Map<String, dynamic> cfg,
  List<String> files,
  List<(double, double)> bounds, {
  int? opusKbps,
}) async {
  final dir = Directory(cfg['audioDir'] as String)..createSync(recursive: true);
  // Every file in the folder ships in the app, so anything from an earlier
  // cut or another format goes.
  for (final old in dir.listSync().whereType<File>()) {
    if (!files.contains(old.uri.pathSegments.last)) old.deleteSync();
  }
  final codec = opusKbps == null
      ? ['-c:a', 'libmp3lame', '-b:a', '48k', '-ac', '1', '-ar', '24000']
      : [
          '-c:a', 'libopus', '-b:a', '${opusKbps}k', '-ac', '1', //
          '-application', 'voip',
        ];
  for (var e = 0; e < files.length; e++) {
    final (s, t) = bounds[e];
    final out = '${dir.path}/${files[e]}';
    final result = await Process.run(ffmpeg, [
      '-hide_banner',
      '-loglevel',
      'error',
      '-y',
      '-ss',
      s.toStringAsFixed(3),
      '-to',
      t.toStringAsFixed(3),
      '-i',
      cfg['master'] as String,
      ...codec,
      out,
    ]);
    if (result.exitCode != 0) _fail('ffmpeg failed on $out:\n${result.stderr}');
    stdout.writeln('cut $out');
  }
}

/// A single-quoted Dart string literal.
String _str(String s) {
  final escaped = s
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$');
  return "'$escaped'";
}

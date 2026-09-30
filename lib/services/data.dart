import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:platform_prep/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads the bundled question bank (7 tests x 100 questions).
class Repo {
  Repo._();
  static final Repo instance = Repo._();

  final List<TestInfo> tests = [];
  final Map<int, List<Question>> _byTest = {};
  final Map<String, Question> _byRef = {};

  Future<void> load() async {
    if (tests.isNotEmpty) return;
    final manifest = jsonDecode(
      await rootBundle.loadString('assets/data/manifest.json'),
    ) as List<dynamic>;
    for (final m in manifest) {
      final info = TestInfo.fromJson(m as Map<String, dynamic>);
      final doc = jsonDecode(
        await rootBundle.loadString('assets/data/test_${info.id}.json'),
      ) as Map<String, dynamic>;
      final qs = (doc['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>, info.id))
          .toList();
      _byTest[info.id] = qs;
      for (final q in qs) {
        _byRef[q.ref] = q;
      }
      tests.add(info);
    }
  }

  List<Question> questionsOf(int testId) => _byTest[testId] ?? const [];

  Question? find(String ref) => _byRef[ref];

  int get totalQuestions => _byRef.length;

  List<Question> randomQuestions(int count) {
    final all = _byRef.values.toList()..shuffle(Random());
    return all.take(count).toList();
  }
}

/// Saves finished attempts on the device.
class Store {
  static const _key = 'attempts_v1';

  static Future<List<Attempt>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    final out = <Attempt>[];
    for (final s in raw) {
      try {
        out.add(Attempt.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // skip a corrupted entry
      }
    }
    out.sort((a, b) => b.time.compareTo(a.time));
    return out;
  }

  static Future<void> add(Attempt a) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode(a.toJson()));
    await prefs.setStringList(_key, raw);
  }

  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    final keep = <String>[];
    for (final s in raw) {
      try {
        final j = jsonDecode(s) as Map<String, dynamic>;
        if (j['id'] != id) keep.add(s);
      } catch (_) {}
    }
    await prefs.setStringList(_key, keep);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

String fmtDuration(int sec) {
  final s = sec < 0 ? 0 : sec;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final r = s % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(r)}' : '${two(m)}:${two(r)}';
}

String fmtDate(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.day)}/${two(t.month)}/${t.year}  ${two(t.hour)}:${two(t.minute)}';
}

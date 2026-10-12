import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:prep_insta/exam.dart';
import 'package:prep_insta/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads the bundled question bank (7 tests x 100 questions).
class Repo {
  Repo._();
  static final Repo instance = Repo._();

  final List<Exam> exams = [];
  final Map<int, List<TestInfo>> _testsByExam = {};
  final Map<int, List<Question>> _byTest = {};
  final Map<String, Question> _byRef = {};

  Future<void> load() async {
    if (exams.isNotEmpty) return;
    final list = jsonDecode(
      await rootBundle.loadString('assets/data/exams.json'),
    ) as List<dynamic>;

    for (final e in list) {
      final exam = Exam.fromJson(e as Map<String, dynamic>);
      final dir = 'assets/data/${exam.key}';

      try {
        final manifest = jsonDecode(
          await rootBundle.loadString('$dir/manifest.json'),
        ) as List<dynamic>;

        final infos = <TestInfo>[];
        for (final m in manifest) {
          final map = Map<String, dynamic>.from(m as Map);
          final localId = map['id'] as int;
          final globalId = exam.base + localId;
          map['id'] = globalId; // make id unique across exams

          final info = TestInfo.fromJson(map);
          final doc = jsonDecode(
            await rootBundle.loadString('$dir/test_$localId.json'),
          ) as Map<String, dynamic>;

          final qs = (doc['questions'] as List<dynamic>)
              .map(
                  (q) => Question.fromJson(q as Map<String, dynamic>, globalId))
              .toList();

          _byTest[globalId] = qs;
          for (final q in qs) {
            _byRef[q.ref] = q;
          }
          infos.add(info);
        }
        _testsByExam[exam.id] = infos;
        exams.add(exam);
      } catch (_) {
        // Exam folder missing or incomplete: skip it instead of crashing.
      }
    }
  }

  List<TestInfo> testsOf(int examId) => _testsByExam[examId] ?? const [];

  List<Question> questionsOf(int testId) => _byTest[testId] ?? const [];

  Question? find(String ref) => _byRef[ref];

  int totalQuestionsOf(int examId) => _byTest.entries
      .where((e) => examIdOfTest(e.key) == examId)
      .fold(0, (sum, e) => sum + e.value.length);

  List<Question> randomQuestions(int count, {required int examId}) {
    final all = _byTest.entries
        .where((e) => examIdOfTest(e.key) == examId)
        .expand((e) => e.value)
        .toList()
      ..shuffle(Random());
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

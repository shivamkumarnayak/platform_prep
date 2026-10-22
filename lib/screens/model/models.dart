class Question {
  const Question({
    required this.testId,
    required this.n,
    required this.text,
    required this.options,
    required this.answer,
    this.image,
    required this.optionImages,
  });

  final int testId;
  final int n; // number inside the original shift (1..100)
  final String text;
  final List<String> options;
  final int answer; // 0..3
  final String? image; // asset-relative path, used when text can't hold the question
  final List<String?> optionImages;

  String get ref => '$testId:$n';

  factory Question.fromJson(Map<String, dynamic> j, int testId) {
    final oi = j['oi'] as List<dynamic>?;
    return Question(
      testId: testId,
      n: j['n'] as int,
      text: j['q'] as String,
      options: (j['o'] as List<dynamic>).map((e) => e as String).toList(),
      answer: j['a'] as int,
      image: j['qi'] as String?,
      optionImages: oi == null
          ? List<String?>.filled(4, null)
          : oi.map((e) => e as String?).toList(),
    );
  }
}

class TestInfo {
  const TestInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.duration,
  });

  final int id;
  final String title;
  final String subtitle;
  final int count;
  final int duration; // minutes

  factory TestInfo.fromJson(Map<String, dynamic> j) => TestInfo(
        id: j['id'] as int,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String,
        count: j['count'] as int,
        duration: j['duration'] as int,
      );
}

/// One finished test. `answers[i]` is the chosen option (0..3) or -1 if skipped.
class Attempt {
  const Attempt({
    required this.id,
    required this.testId,
    required this.title,
    required this.time,
    required this.refs,
    required this.answers,
    required this.durationSec,
    required this.spentSec,
    required this.correct,
    required this.wrong,
    required this.skipped,
  });

  final String id;
  final int testId; // 0 = quick practice
  final String title;
  final DateTime time;
  final List<String> refs;
  final List<int> answers;
  final int durationSec;
  final int spentSec;
  final int correct;
  final int wrong;
  final int skipped;

  int get total => refs.length;
  double get score => correct - wrong / 3.0; // +1 correct, -1/3 wrong
  int get attempted => correct + wrong;
  double get accuracy => attempted == 0 ? 0 : correct * 100.0 / attempted;

  Map<String, dynamic> toJson() => {
        'id': id,
        'testId': testId,
        'title': title,
        'time': time.millisecondsSinceEpoch,
        'refs': refs,
        'answers': answers,
        'durationSec': durationSec,
        'spentSec': spentSec,
        'correct': correct,
        'wrong': wrong,
        'skipped': skipped,
      };

  factory Attempt.fromJson(Map<String, dynamic> j) => Attempt(
        id: j['id'] as String,
        testId: j['testId'] as int,
        title: j['title'] as String,
        time: DateTime.fromMillisecondsSinceEpoch(j['time'] as int),
        refs: (j['refs'] as List<dynamic>).map((e) => e as String).toList(),
        answers: (j['answers'] as List<dynamic>).map((e) => e as int).toList(),
        durationSec: j['durationSec'] as int,
        spentSec: j['spentSec'] as int,
        correct: j['correct'] as int,
        wrong: j['wrong'] as int,
        skipped: j['skipped'] as int,
      );
}

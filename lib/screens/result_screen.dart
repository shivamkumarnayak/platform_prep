import 'package:flutter/material.dart';

import 'data.dart';
import 'models.dart';
import 'question_view.dart';

enum _Filter { all, correct, wrong, skipped }

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.attempt});

  final Attempt attempt;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  _Filter _filter = _Filter.all;

  // 0 = correct, 1 = wrong, 2 = skipped
  int _status(Question q, int chosen) {
    if (chosen < 0) return 2;
    return chosen == q.answer ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.attempt;
    final repo = Repo.instance;

    // Pair each stored answer with its question (skip any question that can't be found).
    final rows = <({int no, Question q, int chosen})>[];
    for (var i = 0; i < a.refs.length; i++) {
      final q = repo.find(a.refs[i]);
      if (q != null) rows.add((no: i + 1, q: q, chosen: a.answers[i]));
    }
    final shown = rows.where((r) {
      final s = _status(r.q, r.chosen);
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.correct:
          return s == 0;
        case _Filter.wrong:
          return s == 1;
        case _Filter.skipped:
          return s == 2;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(a.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: shown.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _header(context, a);
          final r = shown[index - 1];
          return _reviewCard(r.no, r.q, r.chosen);
        },
      ),
    );
  }

  Widget _header(BuildContext context, Attempt a) {
    final cs = Theme.of(context).colorScheme;
    final pct = a.total == 0 ? 0.0 : (a.score / a.total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: cs.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Your score',
                    style: TextStyle(color: cs.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text(
                  '${a.score.toStringAsFixed(2)} / ${a.total}',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: pct, minHeight: 8),
                const SizedBox(height: 4),
                Text(
                  '+1 per correct, -1/3 per wrong',
                  style: TextStyle(
                      fontSize: 12, color: cs.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _stat('Correct', '${a.correct}', Colors.green.shade700),
            _stat('Wrong', '${a.wrong}', Colors.red.shade700),
            _stat('Skipped', '${a.skipped}', Colors.grey.shade700),
          ],
        ),
        Row(
          children: [
            _stat('Accuracy', '${a.accuracy.toStringAsFixed(0)}%', cs.primary),
            _stat('Time used', fmtDuration(a.spentSec), cs.primary),
            _stat('Taken on', fmtDate(a.time).split('  ').first, cs.primary),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final f in _Filter.values)
              ChoiceChip(
                label: Text(_label(f, a)),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _label(_Filter f, Attempt a) {
    switch (f) {
      case _Filter.all:
        return 'All (${a.total})';
      case _Filter.correct:
        return 'Correct (${a.correct})';
      case _Filter.wrong:
        return 'Wrong (${a.wrong})';
      case _Filter.skipped:
        return 'Skipped (${a.skipped})';
    }
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewCard(int no, Question q, int chosen) {
    final s = _status(q, chosen);
    final label = s == 0 ? 'Correct' : (s == 1 ? 'Wrong' : 'Not attempted');
    final color = s == 0
        ? Colors.green.shade700
        : (s == 1 ? Colors.red.shade700 : Colors.grey.shade700);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Q$no',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(label,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            QuestionView(
              question: q,
              selected: chosen,
              review: true,
            ),
            Text(
              'Correct answer: option ${q.answer + 1}',
              style: TextStyle(
                  color: Colors.green.shade700, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

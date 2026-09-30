import 'dart:async';

import 'package:flutter/material.dart';

import 'data.dart';
import 'models.dart';
import 'question_view.dart';
import 'result_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({
    super.key,
    required this.testId,
    required this.title,
    required this.durationMin,
    required this.questions,
  });

  final int testId; // 0 = quick practice
  final String title;
  final int durationMin;
  final List<Question> questions;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late final List<int> _ans = List<int>.filled(widget.questions.length, -1);
  late final List<bool> _marked =
      List<bool>.filled(widget.questions.length, false);
  late final List<bool> _visited =
      List<bool>.filled(widget.questions.length, false);
  final ScrollController _scroll = ScrollController();

  int _i = 0;
  late int _left;
  Timer? _timer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _left = widget.durationMin * 60;
    _visited[0] = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _done) return;
      setState(() => _left--);
      if (_left <= 0) {
        _finish();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _go(int idx) {
    if (idx < 0 || idx >= widget.questions.length) return;
    setState(() {
      _i = idx;
      _visited[idx] = true;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  int get _answered => _ans.where((a) => a >= 0).length;
  int get _markedCount => _marked.where((m) => m).length;

  Future<void> _askSubmit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit test?'),
        content: Text(
          'Answered: $_answered\n'
          'Not answered: ${widget.questions.length - _answered}\n'
          'Marked for review: $_markedCount\n\n'
          'Time left: ${fmtDuration(_left)}',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continue test')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit')),
        ],
      ),
    );
    if (ok == true) _finish();
  }

  Future<void> _finish() async {
    if (_done || !mounted) return;
    _done = true;
    _timer?.cancel();

    // Close any dialog / palette / zoom page that is open on top of this screen
    // (matters when the timer runs out while one of them is showing).
    final route = ModalRoute.of(context);
    if (route != null) {
      Navigator.of(context).popUntil((r) => r == route);
    }

    final qs = widget.questions;
    var c = 0, w = 0, s = 0;
    for (var k = 0; k < qs.length; k++) {
      if (_ans[k] < 0) {
        s++;
      } else if (_ans[k] == qs[k].answer) {
        c++;
      } else {
        w++;
      }
    }
    final total = widget.durationMin * 60;
    final attempt = Attempt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testId: widget.testId,
      title: widget.title,
      time: DateTime.now(),
      refs: qs.map((q) => q.ref).toList(),
      answers: List<int>.of(_ans),
      durationSec: total,
      spentSec: (total - _left).clamp(0, total).toInt(),
      correct: c,
      wrong: w,
      skipped: s,
    );
    await Store.add(attempt);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(attempt: attempt)),
    );
  }

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave the test?'),
        content: const Text('Your progress will be lost and no result will be saved.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Stay')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Leave')),
        ],
      ),
    );
    if (leave == true && mounted) {
      _done = true;
      _timer?.cancel();
      Navigator.of(context).pop();
    }
  }

  Color _statusColor(int k) {
    if (_marked[k]) return Colors.purple;
    if (_ans[k] >= 0) return Colors.green.shade600;
    if (_visited[k]) return Colors.deepOrange;
    return Colors.grey.shade500;
  }

  void _openPalette() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      _legend(Colors.green.shade600, 'Answered'),
                      _legend(Colors.deepOrange, 'Not answered'),
                      _legend(Colors.purple, 'Marked'),
                      _legend(Colors.grey.shade500, 'Not visited'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var k = 0; k < widget.questions.length; k++)
                        InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            _go(k);
                          },
                          child: Container(
                            width: 44,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _statusColor(k),
                              borderRadius: BorderRadius.circular(8),
                              border: k == _i
                                  ? Border.all(color: Colors.black, width: 2.5)
                                  : null,
                            ),
                            child: Text(
                              '${k + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _legend(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration:
              BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_i];
    final last = _i == widget.questions.length - 1;
    final low = _left < 300;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Q ${_i + 1} / ${widget.questions.length}'),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: low ? Colors.red.shade100 : Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined,
                      size: 16,
                      color: low ? Colors.red.shade800 : Colors.black87),
                  const SizedBox(width: 4),
                  Text(
                    fmtDuration(_left),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: low ? Colors.red.shade800 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Question palette',
              icon: const Icon(Icons.grid_view_rounded),
              onPressed: _openPalette,
            ),
            TextButton(onPressed: _askSubmit, child: const Text('Submit')),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuestionView(
                      key: ValueKey(q.ref),
                      question: q,
                      selected: _ans[_i],
                      onSelect: (idx) => setState(
                          () => _ans[_i] = _ans[_i] == idx ? -1 : idx),
                    ),
                    if (_ans[_i] >= 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _ans[_i] = -1),
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Clear response'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _i == 0 ? null : () => _go(_i - 1),
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _marked[_i] = !_marked[_i]),
                        icon: Icon(
                          _marked[_i] ? Icons.flag : Icons.outlined_flag,
                          color: Colors.purple,
                          size: 18,
                        ),
                        label: Text(_marked[_i] ? 'Marked' : 'Mark'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: last ? _askSubmit : () => _go(_i + 1),
                        child: Text(last ? 'Submit' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

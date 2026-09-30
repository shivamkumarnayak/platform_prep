import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data.dart';
import 'models.dart';
import 'question_view.dart';
import 'result_screen.dart';
import 'theme.dart'; // file that contains GalleryThemeData

const _cs = GalleryThemeData.colorScheme;
const _markedColor = Color(0xFF7C3AED);

TextStyle _t(double size, FontWeight w, [Color? c]) => GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: w,
      color: c ?? _cs.onSurface,
      height: 1.3,
    );

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

  // -------------------------------------------------------------- dialogs

  Future<void> _askSubmit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Submit test?', style: _t(20, FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _sumTile('$_answered', 'Answered', GalleryThemeData.successColor),
              const SizedBox(width: 8),
              _sumTile('${widget.questions.length - _answered}', 'Not answered',
                  GalleryThemeData.redColor),
              const SizedBox(width: 8),
              _sumTile('$_markedCount', 'Marked', _markedColor),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Icon(Icons.timer_outlined, size: 18, color: _cs.primary),
              const SizedBox(width: 8),
              Text('Time left: ${fmtDuration(_left)}',
                  style: _t(13, FontWeight.w600)),
            ]),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          _dialogCancel(ctx, 'Continue test'),
          _dialogPrimary(ctx, 'Submit', _cs.primary),
        ],
      ),
    );
    if (ok == true) _finish();
  }

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Leave the test?', style: _t(20, FontWeight.w700)),
        content: Text(
          'Your progress will be lost and no result will be saved.',
          style: _t(13, FontWeight.w500, GalleryThemeData.subtitleColor),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          _dialogCancel(ctx, 'Stay'),
          _dialogPrimary(ctx, 'Leave', GalleryThemeData.redColor),
        ],
      ),
    );
    if (leave == true && mounted) {
      _done = true;
      _timer?.cancel();
      Navigator.of(context).pop();
    }
  }

  Widget _dialogCancel(BuildContext ctx, String label) {
    return TextButton(
      style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: GalleryThemeData.subtitleColor),
      onPressed: () => Navigator.pop(ctx, false),
      child: Text(label, style: _t(14, FontWeight.w600)),
    );
  }

  Widget _dialogPrimary(BuildContext ctx, String label, Color color) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () => Navigator.pop(ctx, true),
      child: Text(label, style: _t(14, FontWeight.w700, Colors.white)),
    );
  }

  Widget _sumTile(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Text(value, style: _t(20, FontWeight.w800, color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: _t(10, FontWeight.w600, GalleryThemeData.subtitleColor)),
        ]),
      ),
    );
  }

  // --------------------------------------------------------------- finish

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

  // -------------------------------------------------------------- palette

  Color _statusColor(int k) {
    if (_marked[k]) return _markedColor;
    if (_ans[k] >= 0) return GalleryThemeData.successColor;
    if (_visited[k]) return GalleryThemeData.redColor;
    return GalleryThemeData.lightGreyColor;
  }

  Color _statusText(int k) => (!_marked[k] && _ans[k] < 0 && !_visited[k])
      ? GalleryThemeData.subtitleColor
      : Colors.white;

  void _openPalette() {
    final notAnswered = _visited.asMap().entries
        .where((e) => e.value && _ans[e.key] < 0 && !_marked[e.key])
        .length;
    final notVisited = _visited.where((v) => !v).length;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Question palette', style: _t(18, FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    children: [
                      _legend(GalleryThemeData.successColor,
                          'Answered $_answered'),
                      _legend(GalleryThemeData.redColor,
                          'Not answered $notAnswered'),
                      _legend(_markedColor, 'Marked $_markedCount'),
                      _legend(GalleryThemeData.inActiveColor,
                          'Not visited $notVisited'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var k = 0; k < widget.questions.length; k++)
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(ctx);
                            _go(k);
                          },
                          child: Container(
                            width: 46,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _statusColor(k),
                              borderRadius: BorderRadius.circular(12),
                              border: k == _i
                                  ? Border.all(color: _cs.primary, width: 3)
                                  : null,
                            ),
                            child: Text('${k + 1}',
                                style:
                                    _t(13, FontWeight.w700, _statusText(k))),
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
              BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: _t(11, FontWeight.w600, GalleryThemeData.subtitleColor)),
      ],
    );
  }

  // ---------------------------------------------------------------- build

  PreferredSizeWidget _appBar(bool low) {
    final n = widget.questions.length;
    return AppBar(
      backgroundColor: _cs.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: IconButton(
        tooltip: 'Leave test',
        icon: const Icon(Icons.close_rounded),
        onPressed: _confirmExit,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ${_i + 1} of $n',
              style: _t(15, FontWeight.w700, Colors.white)),
          Text(widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  _t(10, FontWeight.w500, Colors.white.withValues(alpha: .75))),
        ],
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: low
                ? GalleryThemeData.redColor
                : Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(fmtDuration(_left),
                  style: _t(13, FontWeight.w800, Colors.white)),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Question palette',
          icon: const Icon(Icons.grid_view_rounded),
          onPressed: _openPalette,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: _cs.secondary,
              foregroundColor: _cs.onSecondary,
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _askSubmit,
            child: Text('Submit',
                style: _t(12, FontWeight.w800, _cs.onSecondary)),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: (_i + 1) / n,
          minHeight: 4,
          color: _cs.secondary,
          backgroundColor: Colors.white.withValues(alpha: .18),
        ),
      ),
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
        backgroundColor: GalleryThemeData.bodyBackgroundColor,
        appBar: _appBar(low),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: _cs.primary.withValues(alpha: .08),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _cs.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Q ${_i + 1}',
                                  style: _t(12, FontWeight.w800, _cs.primary)),
                            ),
                            const Spacer(),
                            if (_marked[_i])
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.flag,
                                    size: 16, color: _markedColor),
                                const SizedBox(width: 4),
                                Text('Marked for review',
                                    style: _t(11, FontWeight.w700,
                                        _markedColor)),
                              ]),
                          ]),
                          const SizedBox(height: 14),
                          QuestionView(
                            key: ValueKey(q.ref),
                            question: q,
                            selected: _ans[_i],
                            onSelect: (idx) => setState(
                                () => _ans[_i] = _ans[_i] == idx ? -1 : idx),
                          ),
                        ],
                      ),
                    ),
                    if (_ans[_i] >= 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: GalleryThemeData.subtitleColor),
                            onPressed: () => setState(() => _ans[_i] = -1),
                            icon: const Icon(Icons.clear, size: 18),
                            label: Text('Clear response',
                                style: _t(12, FontWeight.w600,
                                    GalleryThemeData.subtitleColor)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _bottomBar(last),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(bool last) {
    final outlined = OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: _cs.primary,
      disabledForegroundColor: GalleryThemeData.inActiveColor,
      side: BorderSide(color: _cs.primary.withValues(alpha: .5), width: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: outlined,
                  onPressed: _i == 0 ? null : () => _go(_i - 1),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text('Prev',
                      style: _t(13, FontWeight.w700, _i == 0
                          ? GalleryThemeData.inActiveColor
                          : _cs.primary)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: outlined.copyWith(
                    side: WidgetStatePropertyAll(BorderSide(
                        color: _markedColor.withValues(alpha: .6), width: 1.5)),
                    backgroundColor: WidgetStatePropertyAll(_marked[_i]
                        ? _markedColor.withValues(alpha: .1)
                        : Colors.white),
                  ),
                  onPressed: () => setState(() => _marked[_i] = !_marked[_i]),
                  icon: Icon(
                    _marked[_i] ? Icons.flag : Icons.outlined_flag,
                    color: _markedColor,
                    size: 18,
                  ),
                  label: Text(_marked[_i] ? 'Marked' : 'Mark',
                      style: _t(13, FontWeight.w700, _markedColor)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: last ? _cs.secondary : _cs.primary,
                    foregroundColor: last ? _cs.onSecondary : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: last ? _askSubmit : () => _go(_i + 1),
                  child: Text(last ? 'Submit' : 'Next',
                      style: _t(13, FontWeight.w800,
                          last ? _cs.onSecondary : Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
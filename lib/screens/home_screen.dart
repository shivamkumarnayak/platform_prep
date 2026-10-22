import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepmock/screens/model/exam.dart';
import 'package:prepmock/screens/model/models.dart';
import 'package:prepmock/services/data.dart';
import 'package:prepmock/utils/theme.dart';
import 'result_screen.dart';
import 'test_screen.dart';

const _cs = GalleryThemeData.colorScheme;

TextStyle _t(double size, FontWeight w, [Color? c]) => GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: w,
      color: c ?? _cs.onSurface,
      height: 1.3,
    );

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.exam});
  final Exam exam;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  List<Attempt> _attempts = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final all = await Store.load();
    if (!mounted) return;
    setState(() => _attempts =
        all.where((a) => examIdOfTest(a.testId) == widget.exam.id).toList());
  }

  Future<void> _start({
    required int testId,
    required String title,
    required int minutes,
    required List<Question> questions,
  }) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: _t(20, FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _chip(Icons.help_outline, '${questions.length} questions'),
              const SizedBox(width: 8),
              _chip(Icons.timer_outlined, '$minutes min'),
            ]),
            const SizedBox(height: 18),
            _rule(Icons.check_circle, GalleryThemeData.successColor,
                '+1 mark for each correct answer'),
            _rule(
              Icons.cancel,
              GalleryThemeData.redColor,
              widget.exam.hasNegative
                  ? '-${widget.exam.negativeLabel} mark for each wrong answer'
                  : 'No negative marking',
            ),
            _rule(Icons.remove_circle_outline, GalleryThemeData.inActiveColor,
                'No mark for unanswered questions'),
            const SizedBox(height: 10),
            Text('The test is submitted automatically when time runs out.',
                style: _t(12, FontWeight.w500, GalleryThemeData.subtitleColor)),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: GalleryThemeData.subtitleColor),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: _t(14, FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _cs.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Start test',
                style: _t(14, FontWeight.w700, Colors.white)),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TestScreen(
          testId: testId,
          title: title,
          durationMin: minutes,
          questions: questions,
        ),
      ),
    );
    await _refresh();
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GalleryThemeData.bodyBackgroundColor,
      body: Column(
        children: [
          _header(),
          Expanded(child: _tab == 0 ? _testsTab() : _historyTab()),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: _cs.primaryContainer,
          height: 68,
          labelTextStyle: WidgetStateProperty.resolveWith((s) => _t(
                12,
                s.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                s.contains(WidgetState.selected)
                    ? _cs.primary
                    : GalleryThemeData.inActiveColor,
              )),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.lightbulb_outline),
              selectedIcon: Icon(Icons.lightbulb, color: _cs.primary),
              label: 'Tests',
            ),
            NavigationDestination(
              icon: const Icon(Icons.history),
              selectedIcon: Icon(Icons.history, color: _cs.primary),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- header

  Widget _header() {
    final repo = Repo.instance;
    final exam = widget.exam;
    double? best;
    for (final a in _attempts) {
      if (best == null || a.score > best) best = a.score;
    }
    final onTests = _tab == 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 22),
      decoration: BoxDecoration(
        color: exam
            .color, // each exam gets its own colour (use _cs.primary to keep one colour)
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    BoxDecoration(color: _cs.secondary, shape: BoxShape.circle),
                child: Icon(exam.icon, size: 20, color: _cs.onSecondary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  exam.name, // "RRB JE" or "STET Bihar"
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(20, FontWeight.w800, Colors.white),
                ),
              ),
              if (!onTests && _attempts.isNotEmpty)
                IconButton(
                  tooltip: 'Clear all',
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.white),
                  onPressed: _confirmClear,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            onTests ? '${exam.title}\nMock Tests' : 'My attempts',
            style: _t(26, FontWeight.w700, Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            onTests
                ? 'Practice on real exam questions, on your schedule.'
                : 'Tap an attempt to review your answers.',
            style: _t(12, FontWeight.w500, Colors.white.withValues(alpha: .8)),
          ),
          if (onTests) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                _stat('${repo.testsOf(exam.id).length}', 'Tests'),
                const SizedBox(width: 10),
                _stat('${_attempts.length}', 'Attempts'),
                const SizedBox(width: 10),
                _stat(best == null ? '-' : best.toStringAsFixed(1), 'Best'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: _t(18, FontWeight.w800, Colors.white)),
            Text(label,
                style: _t(
                    11, FontWeight.w500, Colors.white.withValues(alpha: .8))),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ tests tab

  Widget _testsTab() {
    final repo = Repo.instance;
    final tests = repo.testsOf(widget.exam.id);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        _quickPractice(repo),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Full mock tests', style: _t(16, FontWeight.w700)),
        ),
        for (final t in tests) _testTicket(t),
        const SizedBox(height: 6),
        if (widget.exam.note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(widget.exam.note,
                style: _t(11, FontWeight.w500, GalleryThemeData.subtitleColor)),
          ),
      ],
    );
  }

  Widget _quickPractice(Repo repo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cs.secondary.withValues(alpha: .5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(color: _cs.secondary, shape: BoxShape.circle),
            child: Icon(Icons.bolt, color: _cs.onSecondary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick practice', style: _t(15, FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '25 random questions from ${repo.totalQuestionsOf(widget.exam.id)}  -  25 min',
                  style:
                      _t(11, FontWeight.w500, GalleryThemeData.subtitleColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _cs.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _start(
              testId: widget.exam.base,
              title: '${widget.exam.name} quick practice',
              minutes: 25,
              questions: repo.randomQuestions(25, examId: widget.exam.id),
            ),
            child: Text('Start', style: _t(13, FontWeight.w700, Colors.white)),
          ),
        ],
      ),
    );
  }

  /// A test card shaped like a rail ticket: details on the left, a dashed
  /// tear-off line with notches, and the action on the right.
  Widget _testTicket(TestInfo t) {
    final mine = _attempts.where((a) => a.testId == t.id).toList();
    double? best;
    for (final a in mine) {
      if (best == null || a.score > best) best = a.score;
    }
    const stubWidth = 108.0;
    const notch = 16.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _cs.primary.withValues(alpha: .08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: _cs.primary,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 12, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t.title, style: _t(16, FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(t.subtitle,
                              style: _t(12, FontWeight.w500,
                                  GalleryThemeData.subtitleColor)),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, runSpacing: 6, children: [
                            _chip(Icons.help_outline, '${t.count} Qs'),
                            _chip(Icons.timer_outlined, '${t.duration} min'),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  CustomPaint(
                      painter: _DashPainter(GalleryThemeData.lightGreyColor),
                      size: const Size(1, double.infinity)),
                  SizedBox(
                    width: stubWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (best != null) ...[
                          Text(best.toStringAsFixed(2),
                              style: _t(18, FontWeight.w800,
                                  GalleryThemeData.successColor)),
                          Text('Best  -  ${mine.length}x',
                              style: _t(10, FontWeight.w500,
                                  GalleryThemeData.subtitleColor)),
                          const SizedBox(height: 8),
                        ],
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                mine.isEmpty ? _cs.primary : Colors.white,
                            foregroundColor:
                                mine.isEmpty ? Colors.white : _cs.primary,
                            side: BorderSide(color: _cs.primary, width: 1.5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () => _start(
                            testId: t.id,
                            title: t.title,
                            minutes: t.duration,
                            questions: Repo.instance.questionsOf(t.id),
                          ),
                          child: Text(
                            mine.isEmpty ? 'Start' : 'Retake',
                            style: _t(13, FontWeight.w700,
                                mine.isEmpty ? Colors.white : _cs.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Ticket notches
          for (final top in [true, false])
            Positioned(
              right: stubWidth - notch / 2,
              top: top ? -notch / 2 : null,
              bottom: top ? null : -notch / 2,
              child: Container(
                width: notch,
                height: notch,
                decoration: BoxDecoration(
                  color: GalleryThemeData.bodyBackgroundColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- history tab

  Widget _historyTab() {
    if (_attempts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                    color: _cs.primaryContainer, shape: BoxShape.circle),
                child: Icon(Icons.assignment_outlined,
                    size: 40, color: _cs.primary),
              ),
              const SizedBox(height: 20),
              Text('No attempts yet', style: _t(17, FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                'Take a mock test and your results will appear here.',
                textAlign: TextAlign.center,
                style: _t(13, FontWeight.w500, GalleryThemeData.subtitleColor),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => setState(() => _tab = 0),
                child: Text('Browse tests',
                    style: _t(13, FontWeight.w700, Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      itemCount: _attempts.length,
      itemBuilder: (context, i) {
        final a = _attempts[i];
        final pct = a.total == 0 ? 0.0 : (a.score / a.total).clamp(0.0, 1.0);
        final ringColor = pct >= .6
            ? GalleryThemeData.successColor
            : pct >= .35
                ? _cs.secondary
                : GalleryThemeData.redColor;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _cs.primary.withValues(alpha: .07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ResultScreen(attempt: a),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: pct,
                              strokeWidth: 5,
                              strokeCap: StrokeCap.round,
                              color: ringColor,
                              backgroundColor: GalleryThemeData.lightGreyColor,
                            ),
                          ),
                          Text('${(pct * 100).round()}%',
                              style: _t(12, FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title, style: _t(15, FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(fmtDate(a.time),
                              style: _t(11, FontWeight.w500,
                                  GalleryThemeData.subtitleColor)),
                          const SizedBox(height: 8),
                          Text(
                            'Score ${a.score.toStringAsFixed(2)} / ${a.total}',
                            style: _t(12, FontWeight.w700, _cs.primary),
                          ),
                          const SizedBox(height: 6),
                          Wrap(spacing: 10, children: [
                            _mini(Icons.check_circle,
                                GalleryThemeData.successColor, '${a.correct}'),
                            _mini(Icons.cancel, GalleryThemeData.redColor,
                                '${a.wrong}'),
                            _mini(Icons.remove_circle_outline,
                                GalleryThemeData.inActiveColor, '${a.skipped}'),
                          ]),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: Icon(Icons.delete_outline,
                          color: GalleryThemeData.inActiveColor),
                      onPressed: () async {
                        await Store.remove(a.id);
                        await _refresh();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete all attempts?', style: _t(18, FontWeight.w700)),
        content: Text('This cannot be undone.',
            style: _t(13, FontWeight.w500, GalleryThemeData.subtitleColor)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: GalleryThemeData.subtitleColor),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: _t(14, FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GalleryThemeData.redColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: _t(14, FontWeight.w700, Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await Store.clear();
      await _refresh();
    }
  }

  // -------------------------------------------------------------- helpers

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: _cs.primary),
        const SizedBox(width: 5),
        Text(text, style: _t(11, FontWeight.w600, _cs.primary)),
      ]),
    );
  }

  Widget _mini(IconData icon, Color color, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 3),
      Text(text, style: _t(12, FontWeight.w600)),
    ]);
  }

  Widget _rule(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: _t(13, FontWeight.w500))),
      ]),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    double y = 10;
    while (y < size.height - 10) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 5), p);
      y += 10;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

import 'package:flutter/material.dart';
import 'gallery_theme_data.dart';
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

  // Palette, all taken from GalleryThemeData
  static const _cs = GalleryThemeData.colorScheme;
  static final Color _ok = GalleryThemeData.successColor;
  static const Color _okDark = Color(0xff4A8A26); // readable on light bg
  static final Color _bad = GalleryThemeData.redColor;
  static final Color _skip = GalleryThemeData.greyShadedColor;
  static final Color _bg = GalleryThemeData.bodyBackgroundColor;
  static final Color _title = GalleryThemeData.primaryFontColor;
  static final Color _sub = GalleryThemeData.subtitleColor;

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
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          a.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _title,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _bg,
        surfaceTintColor: _bg,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        itemCount: shown.isEmpty ? 2 : shown.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _header(context, a);
          if (shown.isEmpty) return _emptyState();
          final r = shown[index - 1];
          return _reviewCard(r.no, r.q, r.chosen);
        },
      ),
    );
  }

  // ───────────────────────── Header ─────────────────────────

  Widget _header(BuildContext context, Attempt a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _scoreHero(a),
        const SizedBox(height: 14),
        Row(
          children: [
            _outcomeTile('Correct', '${a.correct}', Icons.check_rounded, _ok,
                _okDark, _ok.withValues(alpha: 0.14)),
            const SizedBox(width: 10),
            _outcomeTile('Wrong', '${a.wrong}', Icons.close_rounded, _bad, _bad,
                _bad.withValues(alpha: 0.10)),
            const SizedBox(width: 10),
            _outcomeTile('Skipped', '${a.skipped}', Icons.remove_rounded, _skip,
                _skip, GalleryThemeData.lightGreyColor),
          ],
        ),
        const SizedBox(height: 14),
        _detailsStrip(a),
        const SizedBox(height: 22),
        Text(
          'Review answers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _title,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in _Filter.values) ...[
                _filterChip(f, a),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  /// The one memorable element: a big animated score ring on a deep-blue card.
  Widget _scoreHero(Attempt a) {
    final pct = a.total == 0 ? 0.0 : (a.score / a.total).clamp(0.0, 1.0);
    final message = _message(pct);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cs.primary,
            Color.lerp(_cs.primary, Colors.black, 0.28)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _cs.primary.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: v,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: _cs.secondary, // amber accent
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        a.score.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'out of ${a.total}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.$1,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.$2,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+1 correct  |  -1/3 wrong',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _message(double pct) {
    if (pct >= 0.8) return ('Excellent work', 'You are well prepared. Keep this pace.');
    if (pct >= 0.5) return ('Good effort', 'Review the wrong answers to push your score higher.');
    if (pct > 0) return ('Keep practising', 'Go through each answer below and learn from it.');
    return ('Fresh start', 'Review the answers below and try again.');
  }

  Widget _outcomeTile(String label, String value, IconData icon, Color iconColor,
      Color valueColor, Color tint) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: GalleryThemeData.whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GalleryThemeData.lightGreyColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: _sub),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsStrip(Attempt a) {
    final date = fmtDate(a.time).split('  ').first;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _detail(Icons.track_changes_rounded, 'Accuracy',
                '${a.accuracy.toStringAsFixed(0)}%'),
            _vDivider(),
            _detail(Icons.timer_outlined, 'Time used', fmtDuration(a.spentSec)),
            _vDivider(),
            _detail(Icons.event_rounded, 'Taken on', date),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => VerticalDivider(
        width: 1,
        thickness: 1,
        color: _cs.primary.withValues(alpha: 0.15),
      );

  Widget _detail(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: _cs.primary),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _title,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: _sub)),
        ],
      ),
    );
  }

  Widget _filterChip(_Filter f, Attempt a) {
    final selected = _filter == f;
    return GestureDetector(
      onTap: () => setState(() => _filter = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _cs.primary : GalleryThemeData.whiteColor,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? _cs.primary : GalleryThemeData.lightGreyColor,
          ),
        ),
        child: Text(
          _label(f, a),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _sub,
          ),
        ),
      ),
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

  // ───────────────────────── Review list ─────────────────────────

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: GalleryThemeData.inActiveColor),
          const SizedBox(height: 10),
          Text(
            'No questions in this filter',
            style: TextStyle(fontSize: 13, color: _sub),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(int no, Question q, int chosen) {
    final s = _status(q, chosen);
    final label = s == 0 ? 'Correct' : (s == 1 ? 'Wrong' : 'Not attempted');
    final accent = s == 0 ? _ok : (s == 1 ? _bad : _skip);
    final textColor = s == 0 ? _okDark : (s == 1 ? _bad : _skip);
    final icon = s == 0
        ? Icons.check_circle_rounded
        : (s == 1 ? Icons.cancel_rounded : Icons.remove_circle_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: GalleryThemeData.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GalleryThemeData.lightGreyColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status stripe on the left edge
              Container(width: 5, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _cs.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Q$no',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _cs.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 16, color: textColor),
                                const SizedBox(width: 4),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      QuestionView(
                        question: q,
                        selected: chosen,
                        review: true,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _ok.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded,
                                size: 18, color: _okDark),
                            const SizedBox(width: 8),
                            Text(
                              'Correct answer: option ${q.answer + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _okDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
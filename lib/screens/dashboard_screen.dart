import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepmock/screens/about_screen.dart';
import 'package:prepmock/screens/feedback_screen.dart';
import 'package:prepmock/screens/model/exam.dart';
import 'package:prepmock/screens/model/models.dart';
import 'package:prepmock/screens/privacy_policy.dart';
import 'package:prepmock/services/data.dart';
import 'package:prepmock/utils/theme.dart';
import 'package:prepmock/utils/utility.dart';
import 'package:prepmock/widgets/app_drawer.dart';
import 'home_screen.dart';

const _cs = GalleryThemeData.colorScheme;

TextStyle _t(double size, FontWeight w, [Color? c]) => GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: w,
      color: c ?? _cs.onSurface,
      height: 1.3,
    );

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Attempt> _attempts = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final a = await Store.load();
    if (!mounted) return;
    setState(() => _attempts = a);
  }

  Future<void> _open(Exam exam) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => HomeScreen(exam: exam)),
    );
    await _refresh();
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }


  @override
  Widget build(BuildContext context) {
    final repo = Repo.instance;
    return WillPopScope(
      onWillPop: () async {
        var value = await Utility.exitPopup(
            context, '', 'Do you really want to exit the app?', null);
        if (value != null) {
          return Future.value(value);
        } else {
          return Future.value(false);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: GalleryThemeData.bodyBackgroundColor,
        drawer: AppDrawer(
          onExamTap: _open,
          onFeedbackTap: () =>_push(const FeedbackScreen()),
          onPrivacyTap: () => _push(const PrivacyScreen()),
          onAboutTap: () => _push(const AboutScreen()),
        ),
        body: Column(
          children: [
            _header(repo),
            Expanded(
              child: repo.exams.isEmpty
                  ? Center(
                      child: Text('No exams found',
                          style: _t(14, FontWeight.w500,
                              GalleryThemeData.subtitleColor)),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text('Choose your exam',
                              style: _t(16, FontWeight.w700)),
                        ),
                        for (final e in repo.exams) _examCard(repo, e),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(Repo repo) {
    final totalTests =
        repo.exams.fold<int>(0, (s, e) => s + repo.testsOf(e.id).length);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 22),
      decoration: BoxDecoration(
        color: _cs.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _logoButton(),
            const SizedBox(width: 10),
            Text('PrepMock', style: _t(20, FontWeight.w800, Colors.white)),
          ]),
          const SizedBox(height: 18),
          Text('Mock tests for\nevery exam',
              style: _t(26, FontWeight.w700, Colors.white)),
          const SizedBox(height: 6),
          Text('Pick an exam and start practising.',
              style:
                  _t(12, FontWeight.w500, Colors.white.withValues(alpha: .8))),
          const SizedBox(height: 18),
          Row(children: [
            _stat('${repo.exams.length}', 'Exams'),
            const SizedBox(width: 10),
            _stat('$totalTests', 'Tests'),
            const SizedBox(width: 10),
            _stat('${_attempts.length}', 'Attempts'),
          ]),
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
        child: Column(children: [
          Text(value, style: _t(18, FontWeight.w800, Colors.white)),
          Text(label,
              style:
                  _t(11, FontWeight.w500, Colors.white.withValues(alpha: .8))),
        ]),
      ),
    );
  }

  Widget _logoButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: .9),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Logo fills the full circle
            Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
            ),
            // Ripple on top of the image
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: _cs.primary.withValues(alpha: .25),
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _examCard(Repo repo, Exam e) {
    final tests = repo.testsOf(e.id).length;
    final qs = repo.totalQuestionsOf(e.id);
    final attempts =
        _attempts.where((a) => examIdOfTest(a.testId) == e.id).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: e.color.withValues(alpha: .12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _open(e),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: e.color.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(e.icon, color: e.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.name, style: _t(16, FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(e.subtitle,
                        style: _t(11, FontWeight.w500,
                            GalleryThemeData.subtitleColor)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      _chip('$tests tests', e.color),
                      _chip('$qs Qs', e.color),
                      if (attempts > 0) _chip('$attempts attempts', e.color),
                    ]),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: GalleryThemeData.inActiveColor),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: _t(11, FontWeight.w600, color)),
    );
  }
}

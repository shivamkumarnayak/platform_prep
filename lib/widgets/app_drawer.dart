import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prepmock/screens/model/exam.dart';
import 'package:prepmock/utils/theme.dart';

const _cs = GalleryThemeData.colorScheme;

TextStyle _t(double size, FontWeight w, [Color? c]) => GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: w,
      color: c ?? _cs.onSurface,
      height: 1.3,
    );

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    this.onExamTap,
    this.onRateTap,
    this.onShareTap,
    this.onFeedbackTap,
    this.onAboutTap,
    this.onPrivacyTap,
  });

  /// Called when an exam is tapped in the drawer (drawer is closed first).
  final ValueChanged<Exam>? onExamTap;
  final VoidCallback? onRateTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onFeedbackTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              children: [
                // _item(context,
                //     icon: Icons.star_outline_rounded,
                //     label: 'Rate the app',
                //     onTap: onRateTap),
                // _item(context,
                //     icon: Icons.share_outlined,
                //     label: 'Share with friends',
                //     onTap: onShareTap),
                _item(context,
                    icon: Icons.feedback_outlined,
                    label: 'Feedback',
                    onTap: onFeedbackTap),
                _item(context,
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: onPrivacyTap),
                _item(context,
                    icon: Icons.info_outline_rounded,
                    label: 'About',
                    onTap: onAboutTap),
              ],
            ),
          ),
          _footer(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 24),
      decoration: BoxDecoration(
        color: _cs.primary,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _logo(),
          const SizedBox(height: 14),
          Text('PrepMock', style: _t(20, FontWeight.w800, Colors.white)),
          const SizedBox(height: 4),
          Text('Mock tests for every exam',
              style:
                  _t(12, FontWeight.w500, Colors.white.withValues(alpha: .8))),
        ],
      ),
    );
  }

  /// Same logo style as the dashboard header (not tappable here).
  Widget _logo() {
    return Container(
      width: 64,
      height: 64,
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
        child: Image.asset(
          'assets/images/app_icon.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Icon(icon, color: iconColor ?? _cs.primary),
      title: Text(label, style: _t(14, FontWeight.w600)),
      onTap: () {
        Navigator.of(context).pop(); // close the drawer first
        onTap?.call();
      },
    );
  }

  Widget _footer(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Built with ', style: _quoteStyle),
                const Icon(Icons.favorite_rounded,
                    size: 14, color: Color(0xFFE53935)),
                Text(' for every dreamer', style: _quoteStyle),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '“Every mock test brings you one step closer.”',
              textAlign: TextAlign.center,
              style:
                  _t(11, FontWeight.w500, _cs.onSurface.withValues(alpha: .55))
                      .copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) {
                final info = snap.data;
                final text = info == null
                    ? ''
                    : 'Version ${info.version} (${info.buildNumber})';
                return Text(
                  text,
                  style: _t(
                      11, FontWeight.w600, _cs.onSurface.withValues(alpha: .5)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _quoteStyle =>
      _t(12, FontWeight.w600, _cs.onSurface.withValues(alpha: .7));
}

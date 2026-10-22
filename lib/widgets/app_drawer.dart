import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    this.onAboutTap,
  });

  /// Called when an exam is tapped in the drawer (drawer is closed first).
  final ValueChanged<Exam>? onExamTap;
  final VoidCallback? onRateTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onAboutTap;

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
                _item(context,
                    icon: Icons.star_outline_rounded,
                    label: 'Rate the app',
                    onTap: onRateTap),
                _item(context,
                    icon: Icons.share_outlined,
                    label: 'Share with friends',
                    onTap: onShareTap),
                _item(context,
                    icon: Icons.info_outline_rounded,
                    label: 'About',
                    onTap: onAboutTap),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top, 20, 24),
      decoration: BoxDecoration(
        color: _cs.primary,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration:
                BoxDecoration(color: _cs.secondary, shape: BoxShape.circle),
            child: Icon(Icons.train, size: 28, color: _cs.onSecondary),
          ),
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
}

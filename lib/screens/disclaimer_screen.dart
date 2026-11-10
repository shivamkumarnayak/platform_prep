import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:prepmock/utils/theme.dart';
import 'package:prepmock/widgets/custom_appbar.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  static const String appName = "PrepMock";

  @override
  Widget build(BuildContext context) {
    const cs = GalleryThemeData.colorScheme;
    final tt = GalleryThemeData.textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CustomAppbar(
        mainAxisAlignment: MainAxisAlignment.start,
        icon: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleWidget: Text(
          "Disclaimer",
          style: tt.titleMedium!.copyWith(color: Colors.white),
        ),
        trailingWidget: Container(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Disclaimer for $appName",
                      style: tt.titleLarge!.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Last Updated: November 9, 2026",
                style: tt.bodySmall!.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),

              // Independent App Notice
              Text(
                "$appName is an independent educational application and is NOT affiliated with, endorsed by, or connected to any official examination board, government body, recruitment agency, or testing authority.",
                style: tt.bodySmall!.copyWith(
                  color: GalleryThemeData.redColor,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Section 1
              _buildSection(
                icon: Icons.info_outline_rounded,
                title: "1. General Information Purpose",
                intro:
                    "All mock tests, practice questions, and study materials provided within $appName are intended solely for general reference, practice, and educational self-assessment purposes.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 2
              _buildSection(
                icon: Icons.menu_book_rounded,
                title: "2. Source of Questions & PYQs",
                intro:
                    "The Previous Year Questions (PYQs) and sample test papers featured in this application have been compiled and collated from various publicly available sources and websites across the internet. $appName claims no ownership or exclusive copyright over these original exam papers or official question banks.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 3
              _buildSection(
                icon: Icons.update_rounded,
                title: "3. No Guarantee of Accuracy",
                intro:
                    "While we strive to ensure that answers, explanations, and mock test formats are accurate and up-to-date:",
                bullets: const [
                  _Bullet(
                    text:
                        "We do not guarantee absolute error-free solutions, exact marking schemes, or identical question patterns as actual live exams.",
                  ),
                  _Bullet(
                    text:
                        "Syllabi, exam structures, patterns, and cutoff criteria may change over time without prior notice from respective examination authorities.",
                  ),
                ],
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 4
              _buildSection(
                icon: Icons.verified_user_rounded,
                title: "4. Official Verification Recommended",
                intro:
                    "Users and aspirants are strongly advised to cross-verify all exam notifications, official syllabi, eligibility criteria, and key answers directly from the respective official websites or governing portals of the conducting bodies before making critical academic decisions.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 5
              _buildSection(
                icon: Icons.copyright_rounded,
                title: "5. Intellectual Property & Copyright Notice",
                intro:
                    "If any copyright holder, organization, or board finds any content in this app that infringes upon their rights or intellectual property, please notify us immediately. We are fully committed to reviewing and promptly removing or rectifying any disputed material upon valid notice.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 6
              _buildSection(
                icon: Icons.shield_rounded,
                title: "6. Limitation of Liability",
                intro:
                    "By using $appName, you agree that the developers and creators are not liable for any direct or indirect loss, academic setback, exam disqualification, or inconvenience caused by reliance on the mock tests, materials, or features provided within the application.",
                tt: tt,
              ),
              const SizedBox(height: 28),

              // Highlighted Warning Box
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0.95),
                      cs.primary.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Practice Smart & Stay Updated",
                      style: tt.titleMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$appName is designed solely to aid your exam preparation journey. "
                      "Always rely on official board notifications for final guidelines.",
                      style: tt.bodyLarge!.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String intro,
    required TextTheme tt,
    List<_Bullet> bullets = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueGrey, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: tt.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          intro,
          style: tt.bodyMedium!.copyWith(height: 1.4),
        ),
        if (bullets.isNotEmpty) const SizedBox(height: 8),
        for (final b in bullets)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("•  ", style: tt.bodyMedium!.copyWith(height: 1.4)),
                Expanded(
                  child: Text(
                    b.text,
                    style: tt.bodyMedium!.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bullet {
  final String text;
  const _Bullet({required this.text});
}
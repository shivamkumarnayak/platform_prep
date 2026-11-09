import 'package:flutter/material.dart';
import 'package:prepmock/utils/theme.dart';
import 'package:prepmock/widgets/custom_appbar.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  static const String appName = "PrepMock";
  static const String contactEmail = "shivamkumarnayak100@gmail.com";

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
          "Privacy Policy",
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
                  Icon(Icons.privacy_tip_rounded, color: cs.primary, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Privacy Policy for $appName",
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
                "Effective Date: 9 November, 2026",
                style: tt.bodySmall!.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),

              // Intro
              Text(
                "Welcome to $appName. We respect your privacy and are committed to protecting the personal information you share with us while using our exam mock test application. This Privacy Policy explains what data we collect, how we use it, and how we protect your information.",
                style: tt.bodyMedium!.copyWith(height: 1.4),
              ),
              const Divider(height: 28),

              // Section 1
              _buildSection(
                icon: Icons.person_search_rounded,
                title: "1. Information We Collect",
                intro:
                    "To provide a seamless mock test experience and track your exam performance, we may collect the following types of information:",
                bullets: const [
                  _Bullet(
                    label: "Account & Profile Information",
                    text:
                        "Basic details such as your name, email address, or phone number when you register, log in, or create a profile on $appName.",
                  ),
                  _Bullet(
                    label: "Exam & Performance Data",
                    text:
                        "Mock test scores, attempt history, time taken per test, and bookmarked questions to help track your preparation progress.",
                  ),
                  _Bullet(
                    label: "Device & Technical Information",
                    text:
                        "Anonymous information such as device model, operating system version, app version, and crash logs to optimize app performance and fix bugs.",
                  ),
                ],
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 2
              _buildSection(
                icon: Icons.quiz_rounded,
                title: "2. How We Use Your Information",
                intro:
                    "We use the collected information strictly for educational and app functional purposes, including:",
                bullets: const [
                  _Bullet(
                    text:
                        "Conducting mock tests, scoring your responses, and generating performance analytics.",
                  ),
                  _Bullet(
                    text:
                        "Managing your account and saving your test progress.",
                  ),
                  _Bullet(
                    text:
                        "Improving app functionality, fixing technical issues, and optimizing performance.",
                  ),
                  _Bullet(
                    text:
                        "Sending important updates regarding exam schedules, mock tests, or account notices.",
                  ),
                ],
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 3
              _buildSection(
                icon: Icons.security_rounded,
                title: "3. Permissions Used",
                intro:
                    "$appName requests minimal permissions required for smooth operation:",
                bullets: const [
                  _Bullet(
                    label: "Internet Access",
                    text:
                        "Required to load online mock tests, fetch updated question banks, and sync performance data.",
                  ),
                  _Bullet(
                    label: "Storage Access (Optional)",
                    text:
                        "Required only if you choose to download mock test papers, solution PDFs, or report cards to your device.",
                  ),
                ],
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 4
              _buildSection(
                icon: Icons.link_rounded,
                title: "4. Third-Party Services & Links",
                intro:
                    "Our app may use trusted third-party services for app stability, analytics, or user support, such as:",
                bullets: const [
                  _Bullet(
                    label: "Firebase Analytics / Crashlytics",
                    text:
                        "To monitor app performance and resolve crashes.",
                  ),
                  _Bullet(
                    label: "Google Play Services",
                    text:
                        "For core app infrastructure and authentication.",
                  ),
                  _Bullet(
                    label: "External Links",
                    text:
                        "WhatsApp, Telegram, or email support channels for resolving user queries.",
                  ),
                ],
                footer:
                    "These third-party services operate under their own privacy policies, and we advise users to review them.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 5
              _buildSection(
                icon: Icons.lock_rounded,
                title: "5. Data Security",
                intro:
                    "We prioritize your data security. All connections and data transmissions are handled through secure SSL channels. We take reasonable precautions to protect your personal information and test records against unauthorized access, disclosure, or misuse.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 6
              _buildSection(
                icon: Icons.child_care_rounded,
                title: "6. Children’s Privacy",
                intro:
                    "$appName is designed for students preparing for competitive exams and general learning. We do not knowingly collect personal information from children under the age of 13. If we discover that a child under 13 has provided us with personal data, we will immediately delete it from our systems.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 7
              _buildSection(
                icon: Icons.update_rounded,
                title: "7. Policy Updates",
                intro:
                    "We may update this Privacy Policy from time to time to reflect app improvements or regulatory changes. The latest version will always be accessible within the $appName app and on our Google Play Store listing.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 8
              _buildSection(
                icon: Icons.mail_rounded,
                title: "8. Contact Us",
                intro:
                    "If you have any questions, feedback, or concerns regarding this Privacy Policy, please reach out to us:",
                bullets: const [
                  _Bullet(
                    label: "📧 Email",
                    text: contactEmail,
                  ),
                ],
                footer: "We will respond to your query as soon as possible.",
                tt: tt,
              ),
              const SizedBox(height: 28),

              // Highlighted Info Box
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
                        Icons.privacy_tip_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Your Privacy Matters",
                      style: tt.titleMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$appName is committed to protecting your personal information. "
                      "Practice your tests with confidence.",
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
    String? footer,
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
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (b.label != null)
                          TextSpan(
                            text: "${b.label}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        TextSpan(text: b.text),
                      ],
                    ),
                    style: tt.bodyMedium!.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        if (footer != null) ...[
          const SizedBox(height: 4),
          Text(
            footer,
            style: tt.bodyMedium!.copyWith(height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _Bullet {
  final String? label;
  final String text;
  const _Bullet({this.label, required this.text});
}
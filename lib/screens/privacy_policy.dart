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
                      "Privacy Policy",
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
                "Effective Date: 23 October, 2026",
                style: tt.bodySmall!.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),

              // Intro
              Text(
                "$appName respects your privacy. This Privacy Policy explains how our app handles your information while you practice and take PrepMocks.",
                style: tt.bodyMedium!.copyWith(height: 1.4),
              ),
              const Divider(height: 28),

              // Section 1
              _buildSection(
                icon: Icons.person_off_rounded,
                title: "1. Information We Collect",
                text:
                    "$appName does not collect, sell, or share any personal information from its users.\n\n"
                    "• We do not require you to create an account.\n"
                    "• We do not ask for personal details such as name, email, or phone number.\n"
                    "• We do not collect location data, contacts, photos, or files from your device.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 2
              _buildSection(
                icon: Icons.quiz_rounded,
                title: "2. Test Data & Progress",
                text:
                    "Your test attempts, scores, answers, and progress are used only to show you your results and performance inside the app.\n\n"
                    "• This data is stored locally on your device.\n"
                    "• It is not uploaded to our servers or shared with anyone.\n"
                    "• Clearing the app data or uninstalling the app will permanently remove it.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 3
              _buildSection(
                icon: Icons.link_rounded,
                title: "3. Third-Party Services",
                text:
                    "Our app may open external links for your convenience, such as study resources, official exam websites, or our support contact.\n\n"
                    "Please note: These links open in your device browser or another app. Any information you share there is governed by that service's own privacy policy.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 4
              _buildSection(
                icon: Icons.security_rounded,
                title: "4. Permissions Used",
                text:
                    "The app uses only the minimum permissions necessary to function:\n\n"
                    "• Internet Access – To load question content, updates, and open external links.\n\n"
                    "We do not misuse or sell any data accessed through these permissions.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 5
              _buildSection(
                icon: Icons.child_care_rounded,
                title: "5. Children’s Privacy",
                text:
                    "$appName does not knowingly collect any personal information from children under the age of 13. Since we do not collect personal data from any user, no such information is gathered.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 6
              _buildSection(
                icon: Icons.lock_rounded,
                title: "6. Data Security",
                text:
                    "Since we do not collect or store your personal data on our servers, there is no risk of it being misused by us. Data kept on your device is protected by your device's own security features.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 7
              _buildSection(
                icon: Icons.update_rounded,
                title: "7. Changes to This Privacy Policy",
                text:
                    "We may update this Privacy Policy from time to time. Any changes will be posted within the app or on the Play Store listing, along with the updated effective date.",
                tt: tt,
              ),
              const Divider(height: 28),

              // Section 8
              _buildSection(
                icon: Icons.mail_rounded,
                title: "8. Contact Us",
                text:
                    "If you have any questions or concerns about this Privacy Policy, you can contact us at:\n\n"
                    "📧 $contactEmail",
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
                      "Your Privacy is Safe",
                      style: tt.titleMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$appName does not collect, store, or misuse any personal data. "
                      "Practice your tests with complete peace of mind.",
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
    required String text,
    required TextTheme tt,
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
          text,
          style: tt.bodyMedium!.copyWith(height: 1.4),
        ),
      ],
    );
  }
}

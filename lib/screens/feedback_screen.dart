import 'package:flutter/material.dart';
import 'package:prepmock/utils/theme.dart';
import 'package:prepmock/utils/utility.dart';
import 'package:prepmock/widgets/custom_appbar.dart';
import 'package:prepmock/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const String appName = "PrepMock";
  static const String contactEmail = "shivamkumarnayak100@gmail.com";
  Future<void> _openEmailApp({String type = "General Feedback"}) async {
    final subject = Uri.encodeComponent("$type - $appName");
    final body = Uri.encodeComponent(
      "Hi Team,\n\nI would like to share the following feedback:\n\n",
    );
    final Uri emailUri =
        Uri.parse("mailto:$contactEmail?subject=$subject&body=$body");

    try {
      final launched =
          await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        Utility.showErrorSnackBar(
            context, "Error", "No email app found on device.");
      }
    } catch (_) {
      if (mounted) {
        Utility.showErrorSnackBar(
            context, "Error", "No email app found on device.");
      }
    }
  }

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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        titleWidget: Text(
          "Feedback",
          style: tt.titleMedium!.copyWith(color: Colors.white),
        ),
        trailingWidget: Container(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Scrollable content (keeps the button pinned at the bottom)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "We value your feedback 💌",
                      style: tt.headlineSmall!.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "If you face any issue, find a wrong question or answer, or have suggestions to improve the $appName app, please reach out to us via email.",
                      style: tt.bodyMedium!.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 20),

                    // Feedback types
                    Text(
                      "What would you like to share?",
                      style: tt.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTypeTile(
                      icon: Icons.bug_report_rounded,
                      title: "Report a Bug",
                      description: "Something is not working as expected.",
                      type: "Bug Report",
                      tt: tt,
                      cs: cs,
                    ),
                    const SizedBox(height: 10),
                    _buildTypeTile(
                      icon: Icons.rule_rounded,
                      title: "Wrong Question or Answer",
                      description: "Found a mistake in a test? Let us know.",
                      type: "Question Correction",
                      tt: tt,
                      cs: cs,
                    ),
                    const SizedBox(height: 10),
                    _buildTypeTile(
                      icon: Icons.lightbulb_rounded,
                      title: "Suggest a Feature",
                      description: "Tell us what you would like to see next.",
                      type: "Feature Suggestion",
                      tt: tt,
                      cs: cs,
                    ),
                    const SizedBox(height: 20),

                    // Email box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "📧 Email us at: \n$contactEmail",
                        style: tt.bodyLarge!.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "We usually respond within 24–48 hours. Your feedback helps us improve and help you prepare better 🎯",
                      style: tt.bodyMedium!.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom button
            CustomButton(
              buttonText: "Send Feedback via Email",
              width: MediaQuery.of(context).size.width,
              height: 50,
              buttonRadius: 8,
              isLoading: false,
              isDisable: false,
              onPressed: _openEmailApp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTile({
    required IconData icon,
    required String title,
    required String description,
    required String type,
    required TextTheme tt,
    required ColorScheme cs,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openEmailApp(type: type),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: cs.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: tt.bodySmall!.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

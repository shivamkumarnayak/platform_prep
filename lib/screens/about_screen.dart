import 'package:flutter/material.dart';
import 'package:prepmock/utils/theme.dart';
import 'package:prepmock/widgets/custom_appbar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
          "About Us",
          style: tt.titleMedium!.copyWith(color: Colors.white),
        ),
        trailingWidget: Container(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: cs.primary.withOpacity(0.15),
                    child: const Icon(Icons.person,
                        size: 60, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Shivam Kumar Nayak",
                    style: tt.headlineSmall!.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Flutter & React Native Developer",
                    style: tt.bodyMedium!.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // About Me
            Text(
              "👋 About Me",
              style: tt.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "I am a passionate mobile app developer specializing in Flutter and React Native. "
              "With expertise in building cross-platform apps, I focus on creating elegant, scalable, "
              "and user-friendly solutions. My goal is to deliver apps that combine performance with a "
              "delightful user experience.",
              style: tt.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Skills Section
            Text(
              "💡 What I Do",
              style: tt.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _buildSkillTile(
                  icon: Icons.phone_android,
                  title: "Cross-Platform Apps",
                  description:
                      "Building apps that run seamlessly on Android and iOS.",
                  tt: tt,
                  cs: cs,
                ),
                const SizedBox(height: 10),
                _buildSkillTile(
                  icon: Icons.design_services_rounded,
                  title: "UI/UX Focus",
                  description:
                      "Designing beautiful and intuitive app experiences.",
                  tt: tt,
                  cs: cs,
                ),
                const SizedBox(height: 10),
                _buildSkillTile(
                  icon: Icons.rocket_launch,
                  title: "Performance & Scalability",
                  description:
                      "Optimizing apps to be smooth, fast, and reliable.",
                  tt: tt,
                  cs: cs,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Vision / Closing
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withOpacity(0.9),
                    cs.primary.withOpacity(0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                "This app is built with love and dedication to make Delhi Metro travel easier and smarter for everyone.",
                style: tt.bodyLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTile({
    required IconData icon,
    required String title,
    required String description,
    required TextTheme tt,
    required ColorScheme cs,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: tt.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 4),
                Text(description,
                    style: tt.bodySmall!.copyWith(color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

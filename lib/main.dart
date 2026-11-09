import 'package:flutter/material.dart';
import 'package:prepmock/screens/dashboard_screen.dart';
import 'package:prepmock/services/data.dart';
import 'package:prepmock/utils/theme.dart';
import 'package:prepmock/widgets/skeleton.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MockApp());
}

class MockApp extends StatelessWidget {
  const MockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepMock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          },
        ),
        colorScheme: GalleryThemeData.colorScheme,
        useMaterial3: true,
      ),
      // Dark theme uses the same brand blue as its seed
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E4FA3),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: const _Loader(),
    );
  }
}

class _Loader extends StatefulWidget {
  const _Loader();

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> {
  late final Future<void> _future = Repo.instance.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const _LoadingSkeleton();
        }
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load questions:\n${snap.error}'),
              ),
            ),
          );
        }
        return const DashboardScreen();
      },
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GalleryThemeData.bodyBackgroundColor,
      body: Skel.shimmer(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header block
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Skel.circle(36),
                      const SizedBox(width: 10),
                      Skel.box(width: 140, height: 20),
                    ]),
                    const SizedBox(height: 22),
                    Skel.box(width: 220, height: 26),
                    const SizedBox(height: 10),
                    Skel.box(width: 160, height: 14),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // Card placeholders
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Skel.box(height: 96, radius: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
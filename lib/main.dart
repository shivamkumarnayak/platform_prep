import 'package:flutter/material.dart';

import 'data.dart';
import 'home_screen.dart';
import 'theme.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MockApp());
}

class MockApp extends StatelessWidget {
  const MockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlatformPrep',
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
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
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
        return const HomeScreen();
      },
    );
  }
}
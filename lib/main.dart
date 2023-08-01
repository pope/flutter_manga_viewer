import 'package:dyno/dyno.dart' as dyno;
import 'package:flutter/material.dart';
import 'package:flutter_manga_viewer/models/library.dart';
import 'package:flutter_manga_viewer/providers.dart';
import 'package:flutter_manga_viewer/screens/library.dart';
import 'package:flutter_manga_viewer/screens/loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  // The loading screen does not use any state.
  // ignore: missing_provider_scope
  runApp(const MainApp(
    home: _loadingScreen,
  ));

  dyno.prepare(); // Ignoring return value.
  final library = await loadLibrary();

  runApp(ProviderScope(
    overrides: [
      initialLibraryProvider.overrideWithValue(library),
    ],
    child: const MainApp(
      home: _libraryScreen,
    ),
  ));
}

LibraryScreen _libraryScreen() {
  return const LibraryScreen();
}

LoadingScreen _loadingScreen() {
  return const LoadingScreen();
}

class MainApp extends StatelessWidget {
  final Widget Function() home;

  const MainApp({
    super.key,
    required this.home,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: home(),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.deepPurple,
        ),
      ),
      title: 'Flutter Manga Viewer',
    );
  }
}

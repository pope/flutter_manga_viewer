import 'package:flutter/material.dart';
import 'package:flutter_manga_viewer/screens/library.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(
    child: MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LibraryScreen(),
      title: 'Flutter Manga Viewer',
    );
  }
}

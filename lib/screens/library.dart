import 'package:flutter/material.dart';
import 'package:flutter_manga_viewer/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final String value = ref.watch(helloWorldProvider);
            return Text(value);
          },
        ),
      ),
    );
  }
}

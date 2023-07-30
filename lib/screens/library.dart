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
            final books = ref.watch(sortedBooksProvider);
            return books.when(
              data: (books) {
                if (books.isEmpty) {
                  return const Text('Add some books!');
                }
                return const Text('Got something!');
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stackTrace) => Center(
                child: Text('Error: $err'),
              ),
            );
          },
        ),
      ),
    );
  }
}

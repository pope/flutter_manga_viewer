import 'package:flutter/material.dart';
import 'package:flutter_manga_viewer/models/book.dart';
import 'package:flutter_manga_viewer/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookCardWidget extends ConsumerWidget {
  final Book book;

  const BookCardWidget({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const height = 350.0;
    const width = 250.0;

    final bytes = ref.watch(getBookCover(book));
    return Column(children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: bytes.when(
          data: (data) => Image.memory(
            data,
            fit: BoxFit.cover,
            height: height,
            width: width,
            key: const ValueKey(true),
          ),
          error: (err, stackTrace) => Image.asset(
            'assets/waiting.png',
            fit: BoxFit.cover,
            height: height,
            width: width,
            key: const ValueKey(false),
          ),
          loading: () => Image.asset(
            'assets/waiting.png',
            fit: BoxFit.cover,
            height: height,
            width: width,
            key: const ValueKey(false),
          ),
        ),
      ),
      Text(book.defaultTitle),
    ]);
  }
}

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(sortedBooksProvider);

    // If there's an error, show a snackbar about the error.
    ref.listen<AsyncValue<void>>(
      addBooksControllerProvider,
      (prev, cur) {
        cur.whenOrNull(
          error: (error, stackTrace) {
            // show snackbar if an error occurred
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$error'),
                showCloseIcon: true,
              ),
            );
          },
        );
      },
    );

    final isLoading = ref.watch(addBooksControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: Builder(
        builder: (context) {
          if (books.isEmpty) {
            return const Center(
              child: Text('Add some books!'),
            );
          }
          return SafeArea(
            minimum: const EdgeInsets.all(20.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300.0,
                crossAxisSpacing: 20.0,
                mainAxisExtent: 400.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: books.length,
              itemBuilder: (BuildContext itemContext, int index) =>
                  BookCardWidget(book: books[index]),
              primary: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add books to your library',
        onPressed: isLoading
            ? null
            : () {
                ref.read(addBooksControllerProvider.notifier).go();
              },
        child: const Icon(Icons.add),
      ),
    );
  }
}

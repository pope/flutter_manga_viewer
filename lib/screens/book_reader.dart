import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manga_viewer/models/book.dart';
import 'package:flutter_manga_viewer/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookReader extends StatefulWidget {
  final Book book;

  const BookReader({super.key, required this.book});

  @override
  State<BookReader> createState() => _BookReaderState();
}

class _BookReaderState extends State<BookReader> {
  int _pageNum = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.defaultTitle),
      ),
      body: Center(
        child: Consumer(builder: (context, ref, child) {
          final images = ref.watch(getBookImages(widget.book));

          return images.when(
            data: (data) {
              return CallbackShortcuts(
                bindings: <ShortcutActivator, VoidCallback>{
                  const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                    if (_pageNum > 0) {
                      setState(() => _pageNum--);
                    }
                  },
                  const SingleActivator(LogicalKeyboardKey.arrowRight): () {
                    if (_pageNum < data.length - 1) {
                      setState(() => _pageNum++);
                    }
                  },
                },
                child: Focus(
                  autofocus: true,
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 60),
                      child: Image.memory(
                        data[_pageNum],
                        key: ValueKey(_pageNum),
                      )),
                ),
              );
            },
            error: (err, stack) {
              // TODO(pope): Handle this
              log('Unable to show images', error: err, stackTrace: stack);
              return const CircularProgressIndicator();
            },
            loading: () => const CircularProgressIndicator(),
          );
        }),
      ),
    );
  }
}

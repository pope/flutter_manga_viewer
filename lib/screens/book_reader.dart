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
          final imageCount = ref.watch(getBookImagesCount(widget.book));
          final image = ref.watch(getBookImage((widget.book, _pageNum)));

          return CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                if (_pageNum > 0) {
                  setState(() => _pageNum--);
                }
              },
              const SingleActivator(LogicalKeyboardKey.arrowRight): () {
                if (_pageNum < imageCount - 1) {
                  setState(() => _pageNum++);
                }
              },
            },
            child: Focus(
              autofocus: true,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: image.when(
                  data: (data) => Image.memory(
                    data,
                    key: ValueKey(_pageNum),
                  ),
                  error: (error, stackTrace) {
                    log(
                      'Unable to load image',
                      error: error,
                      stackTrace: stackTrace,
                    );
                    return Center(
                      key: ValueKey(_pageNum * 31 + 1),
                      child: Text('Oops: ${_pageNum + 1}'),
                    );
                  },
                  loading: () => Center(
                    key: ValueKey(_pageNum * 31),
                    child: Text('${_pageNum + 1}'),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

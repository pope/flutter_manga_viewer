import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manga_viewer/models/book.dart';

@immutable
class Library {
  final IMap<String, Book> books;

  const Library({
    required this.books,
  });

  Library.fromBooksList(Iterable<Book> books)
      : books = IMap.fromValues(
          keyMapper: (book) => book.id,
          values: books,
          config: const ConfigMap(sort: false),
        );
}

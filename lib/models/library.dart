import 'dart:convert';
import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manga_viewer/models/book.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<File> getLibraryJsonFile() async {
  var dir = await getApplicationSupportDirectory();
  var name = p.join(dir.path, 'library.json');
  return File(name);
}

Future<Library> loadLibrary() async {
  final f = await getLibraryJsonFile();
  try {
    final source = await f.readAsString();
    final json = jsonDecode(source);
    return Library.fromJson(json);
  } catch (e) {
    final lib = Library(
      books: <String, Book>{}.lock,
    );
    await saveLibrary(lib);
    return lib;
  }
}

Future<void> saveLibrary(Library library) async {
  final f = await getLibraryJsonFile();
  final json = const JsonEncoder.withIndent("  ").convert(library.toJson());
  await f.writeAsString(json);
}

@immutable
class Library {
  final String version;
  final IMap<String, Book> books;

  const Library({
    required this.books,
  }) : version = "1.0.0";

  Library.fromJson(Map<String, dynamic> json)
      : books = IMap.fromValues(
          keyMapper: (book) => book.id,
          values: (json['books'] as List<dynamic>)
              .map((b) => Book.fromJson(b))
              .toList(),
          config: const ConfigMap(sort: false),
        ),
        version = json['version']!;

  const Library.withVersion({
    required this.books,
    required this.version,
  });

  bool get isEmpty {
    return books.isEmpty;
  }

  Library copyWith({
    IMap<String, Book>? books,
  }) {
    return Library.withVersion(
      version: version,
      books: books ?? this.books,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'books': books.values.map((b) => b.toJson()).asList(),
    };
  }

  Library withNewBooks(Iterable<Book> newBooks) {
    return copyWith(
        books:
            books.addEntries(newBooks.map((book) => MapEntry(book.id, book))));
  }
}

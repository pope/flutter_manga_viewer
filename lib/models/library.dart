import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manga_viewer/models/book.dart';

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
          values: json['books']!.map((b) => Book.fromJson(b)),
          config: const ConfigMap(sort: false),
        ),
        version = json['version']!;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'books': books.values.map((b) => b.toJson()),
    };
  }
}

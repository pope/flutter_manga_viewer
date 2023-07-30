import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

@immutable
class Book {
  final String id;
  final String path;

  final String? title;
  final String? author;

  const Book({
    required this.id,
    required this.path,
    this.author,
    this.title,
  });

  Book.create({
    required this.path,
  })  : id = const Uuid().v4(),
        title = null,
        author = null;

  String get defaultTitle {
    return title ?? p.basenameWithoutExtension(path);
  }

  Book copyWith({
    String? author,
    String? title,
  }) {
    return Book(
      id: id,
      path: path,
      author: author ?? this.author,
      title: title ?? this.title,
    );
  }
}
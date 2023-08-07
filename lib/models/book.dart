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

  Book.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        path = json['path']!,
        author = json['author'],
        title = json['title'];

  String get defaultTitle {
    return title ?? p.basenameWithoutExtension(path);
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is Book &&
          other.id == id &&
          other.path == path &&
          other.author == author &&
          other.title == title);

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'author': author,
      'title': title,
    };
  }
}

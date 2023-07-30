import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_manga_viewer/models/book.dart';
import 'package:flutter_manga_viewer/models/library.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final libraryProvider =
    AsyncNotifierProvider<LibraryNotifier, Library>(() => LibraryNotifier());

class LibraryNotifier extends AsyncNotifier<Library> {
  @override
  Future<Library> build() async {
    return Library(
      books: <String, Book>{}.lock,
    );
  }
}

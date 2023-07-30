import 'dart:convert';
import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_manga_viewer/models/book.dart';
import 'package:flutter_manga_viewer/models/library.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final libraryFileProvider = FutureProvider((ref) async {
  var dir = await getApplicationSupportDirectory();
  var name = p.join(dir.path, 'library.json');
  return File(name);
});

final libraryProvider =
    AsyncNotifierProvider<LibraryNotifier, Library>(() => LibraryNotifier());

final librarySortTypeProvider = StateProvider(
  (ref) => LibrarySortType.none,
);

final sortedBooksProvider = FutureProvider<Iterable<Book>>((ref) async {
  final librarySortType = ref.watch(librarySortTypeProvider);
  final library = await ref.watch(libraryProvider.future);

  switch (librarySortType) {
    case LibrarySortType.none:
      return library.books.values;
    case LibrarySortType.title:
      return library.books.toValueIList(
        sort: true,
        compare: (a, b) => a.defaultTitle.compareTo(b.defaultTitle),
      );
    default:
      throw UnimplementedError('Unsupported sort type: $librarySortType');
  }
});

class LibraryNotifier extends AsyncNotifier<Library> {
  @override
  Future<Library> build() async {
    final f = await ref.read(libraryFileProvider.future);
    try {
      final source = await f.readAsString();
      final json = jsonDecode(source);
      return Library.fromJson(json);
    } catch (e) {
      final lib = Library(
        books: <String, Book>{}.lock,
      );
      final json = const JsonEncoder.withIndent("    ").convert(lib.toJson());
      await f.writeAsString(json);
      return lib;
    }
  }
}

enum LibrarySortType {
  none,
  title,
}

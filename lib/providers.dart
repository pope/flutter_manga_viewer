import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_manga_viewer/models/book.dart';
import 'package:flutter_manga_viewer/models/library.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final libraryProvider =
    AsyncNotifierProvider<LibraryNotifier, Library>(() => LibraryNotifier());

final librarySortTypeProvider = StateProvider<LibrarySortType>(
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
    return Library(
      books: <String, Book>{}.lock,
    );
  }
}

enum LibrarySortType {
  none,
  title,
}

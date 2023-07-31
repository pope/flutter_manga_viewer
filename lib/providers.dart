import 'dart:convert';
import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_manga_viewer/models/book.dart';
import 'package:flutter_manga_viewer/models/library.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final addBooksControllerProvider =
    StateNotifierProvider<AddBooksController, AsyncValue<void>>((ref) {
  final libraryNotifier = ref.watch(libraryProvider.notifier);
  return AddBooksController(
    libraryNotifier: libraryNotifier,
  );
});

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

class AddBooksController extends StateNotifier<AsyncValue<void>> {
  final LibraryNotifier libraryNotifier;

  AddBooksController({required this.libraryNotifier})
      : super(const AsyncValue.data(null));

  Future<void> go() async {
    state = const AsyncValue.loading();
    try {
      await libraryNotifier.pickFilesToAdd();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}

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
      await _save(lib);
      return lib;
    }
  }

  Future<void> pickFilesToAdd() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['cbz'],
      allowMultiple: true,
      type: FileType.custom,
    );
    if (result == null || result.count == 0) {
      return;
    }

    final newState = state.requireValue
        .withNewBooks(result.files.map((f) => Book.create(path: f.path!)));
    await _save(newState);
    state = AsyncValue.data(newState);
  }

  Future<void> _save(Library library) async {
    final f = await ref.read(libraryFileProvider.future);
    final json = const JsonEncoder.withIndent("  ").convert(library.toJson());
    await f.writeAsString(json);
  }
}

enum LibrarySortType {
  none,
  title,
}

import 'package:archive/archive_io.dart';
import 'package:dyno/dyno.dart' as dyno;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_manga_viewer/models/book.dart';
import 'package:flutter_manga_viewer/models/library.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final addBooksControllerProvider =
    StateNotifierProvider.autoDispose<AddBooksController, AsyncValue<void>>(
        (ref) {
  final libraryNotifier = ref.watch(libraryProvider.notifier);
  return AddBooksController(
    libraryNotifier: libraryNotifier,
  );
});

final getBookCover =
    FutureProvider.autoDispose.family<Uint8List, Book>((ref, book) {
  return dyno.run(
    _getBookCover,
    param1: book.path,
  );
});

final getBookImages = FutureProvider.autoDispose
    .family<IList<Uint8List>, Book>((ref, book) async {
  return dyno.run(
    _getBookImages,
    param1: book.path,
  );
});

final initialLibraryProvider =
    Provider<Library>((ref) => throw UnimplementedError());

final libraryProvider =
    NotifierProvider<LibraryNotifier, Library>(() => LibraryNotifier());

final librarySortTypeProvider = StateProvider(
  (ref) => LibrarySortType.none,
);

final sortedBooksProvider = Provider.autoDispose<IList<Book>>((ref) {
  final librarySortType = ref.watch(librarySortTypeProvider);
  final library = ref.watch(libraryProvider);

  switch (librarySortType) {
    case LibrarySortType.none:
      return library.books.toValueIList();
    case LibrarySortType.title:
      return library.books.toValueIList(
        sort: true,
        compare: (a, b) => a.defaultTitle.compareTo(b.defaultTitle),
      );
    default:
      throw UnimplementedError('Unsupported sort type: $librarySortType');
  }
});

Uint8List _getBookCover(String path) {
  const extensions = ['.jpeg', '.jpg', '.png'];
  // TODO(pope): Make this work with app sandbox on MacOS.
  //
  // I'm not sure if it's this exactly, or the file picker. What I observed
  // was that when I used the file_picker, images would load. And the JSON
  // referenced assets on my Desktop. However, when I restarted the app and
  // didn't use the file picker, then I would get a file permissions error.
  //
  // When going to fix this, adjust the macOS entitlements back to:
  //     <key>com.apple.security.app-sandbox</key>
  //     <true/>
  final inputStream = InputFileStream(path);
  final archive = ZipDecoder().decodeBuffer(inputStream);
  // TODO(pope): Add some error handling here.
  // Specifically for when there aren't any images in this archive file.
  final firstImage = archive
      .where((file) => extensions.contains(p.extension(file.name)))
      .reduce((winner, file) =>
          winner.name.compareTo(file.name) <= 0 ? winner : file);
  final outputStream = OutputStream();
  firstImage.writeContent(outputStream);

  return Uint8List.fromList(outputStream.getBytes());
}

IList<Uint8List> _getBookImages(String path) {
  const extensions = ['.jpeg', '.jpg', '.png'];
  // TODO(pope): Make this work with app sandbox on MacOS.
  // See `_getBookCover`.
  final inputStream = InputFileStream(path);
  final archive = ZipDecoder().decodeBuffer(inputStream);
  final candidates = archive
      .where((file) =>
          // Ignore non-images
          extensions.contains(p.extension(file.name)) &&
          // Ignore hidden files. Looking at you MacOS making __MACOSX
          // directories in your zip files.
          !p.basename(file.name).startsWith('.'))
      .asList();
  candidates.sort((a, b) => a.name.compareTo(b.name));
  final images = candidates.map((file) {
    var outputStream = OutputStream();
    file.writeContent(outputStream);
    return Uint8List.fromList(outputStream.getBytes());
  });
  return IList(images);
}

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

class LibraryNotifier extends Notifier<Library> {
  @override
  Library build() {
    return ref.read(initialLibraryProvider);
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

    final newState = state
        .withNewBooks(result.paths.map((path) => Book.create(path: path!)));
    await saveLibrary(newState);
    state = newState;
  }
}

enum LibrarySortType {
  none,
  title,
}

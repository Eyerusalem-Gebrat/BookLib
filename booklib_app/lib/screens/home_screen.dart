import 'package:flutter/material.dart';
import 'package:booklib_app/screens/landing_screen.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/auth_service.dart';
import 'package:booklib_app/services/book_service.dart';
import 'package:booklib_app/screens/password_reset_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:booklib_app/services/poster_picker.dart';

// TEMPORARY: a screen to test the logic. 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _books = BookService();
  String _output = 'Press a button to test the API.';
  int? _lastId; // the id of the book we just listed or created
    String? _posterUrl; // the poster of the last created or updated book

  Future<void> _run(String label, Future<String> Function() action) async {
    setState(() => _output = '$label...');

    String result;
    try {
      result = await action();
    } on ApiException catch (e) {
      // A 401 is handled centrally: SessionManager already sent the user to the start screen
      if (e.isUnauthorized) return;
      result = 'ERROR ${e.statusCode}: ${e.message}\nFields: ${e.fieldErrors}';
    } catch (e) {
      result = 'ERROR: $e';
    }

    if (!mounted) return;
    setState(() => _output = result);
  }

  Future<void> _goToLogin() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }

  Future<String> _list() async {
    final books = await _books.getBooks();
    if (books.isNotEmpty) _lastId = books.first.id;

    if (books.isEmpty) return 'No books yet.';
    return books
        .map((b) => '#${b.id} ${b.title} (${b.statusLabel}, ${b.percent}%)')
        .join('\n');
  }

  Future<String> _create() async {
    final book = await _books.createBook(
      title: 'Test Book ${DateTime.now().millisecondsSinceEpoch % 1000}',
      author: 'Test Author',
      genre: 'Fiction',
      description: 'Created from the app',
      status: 'reading',
      totalPages: 300,
      currentPage: 120,
    );
    _lastId = book.id;
    return 'Created #${book.id} ${book.title} (${book.percent}%)';
  }

  Future<String> _update() async {
    final id = _lastId;
    if (id == null) return 'Press "List" or "Create" first.';

    final book = await _books.updateBook(
      id,
      title: 'Edited Book',
      author: 'Edited Author',
      status: 'finished', // the server should set current_page = total_pages
      totalPages: 300,
      currentPage: 10,
    );
    return 'Updated #${book.id}: ${book.statusLabel}, '
        '${book.currentPage}/${book.totalPages} (${book.percent}%)';
  }

  Future<String> _missing() async {
    await _books.getBook(999999);
    return 'Unexpected: the book was found';
  }

  // Put the id of a book that belongs to ANOTHER user here
  static const int _otherUsersBookId = 0;

  Future<String> _forbidden() async {
    await _books.getBook(_otherUsersBookId);
    return 'Unexpected: the server let us open it';
  }
  Future<String> _createWithPoster() async {
    final poster = await PosterPicker.pick(ImageSource.gallery);
    if (poster == null) return 'No image chosen.';

    final book = await _books.createBook(
      title: 'Poster Book ${DateTime.now().millisecondsSinceEpoch % 1000}',
      author: 'Test Author',
      status: 'want_to_read',
      totalPages: 200,
      currentPage: 0,
      poster: poster,
    );

    _lastId = book.id;
    if (mounted) setState(() => _posterUrl = book.posterUrl);
    return 'Created #${book.id} with poster:\n${book.posterUrl}';
  }

  Future<String> _changePoster() async {
    final id = _lastId;
    if (id == null) return 'Press "List" or "Create" first.';

    final poster = await PosterPicker.pick(ImageSource.gallery);
    if (poster == null) return 'No image chosen.';

    // The update needs every required field, so load the current values first
    final current = await _books.getBook(id);

    final book = await _books.updateBook(
      id,
      title: current.title,
      author: current.author,
      genre: current.genre,
      description: current.description,
      status: current.status,
      totalPages: current.totalPages,
      currentPage: current.currentPage,
      poster: poster,
    );

    if (mounted) setState(() => _posterUrl = book.posterUrl);
    return 'Updated the poster of #${book.id}:\n${book.posterUrl}';
  }

  Future<String> _delete() async {
    final id = _lastId;
    if (id == null) return 'Press "List" or "Create" first.';

    await _books.deleteBook(id);
    _lastId = null;
    return 'Deleted #$id';
  }

  Future<String> _invalid() async {
    // An empty title and pages read > total pages: should give validation errors
    await _books.createBook(
      title: '',
      author: 'x',
      status: 'reading',
      totalPages: 10,
      currentPage: 99,
    );
    return 'Unexpected: the server accepted invalid data';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API tester'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: _goToLogin,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                    onPressed: () => _run('List', _list),
                    child: const Text('List')),
                FilledButton(
                    onPressed: () => _run('Create', _create),
                    child: const Text('Create')),
                FilledButton(
                    onPressed: () => _run('Update', _update),
                    child: const Text('Update')),
                FilledButton(
                    onPressed: () => _run('Delete', _delete),
                    child: const Text('Delete')),
                FilledButton.tonal(
                    onPressed: () => _run('Invalid create', _invalid),
                    child: const Text('Invalid data')),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PasswordTesterScreen()),
                  ),
                  child: const Text('Password tests'),
                ),
                FilledButton(
                    onPressed: () => _run('Create with poster', _createWithPoster),
                    child: const Text('Create + poster')),
                FilledButton(
                    onPressed: () => _run('Change poster', _changePoster),
                    child: const Text('Change poster')),
                FilledButton.tonal(
                    onPressed: () => _run('Missing book', _missing),
                    child: const Text('Missing book (404)')),
                FilledButton.tonal(
                    onPressed: () => _run('Other user book', _forbidden),
                    child: const Text("Other user's book (403)")),
              ],
            ),
            const SizedBox(height: 16),
            if (_posterUrl != null)
              Image.network(
                _posterUrl!,
                height: 140,
                errorBuilder: (_, _, _) => const Text('The poster could not be loaded'),
              ),
            Expanded(
              child: SingleChildScrollView(child: SelectableText(_output)),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:booklib_app/models/book.dart';
import 'package:booklib_app/services/api_client.dart';

class BookService {
  final ApiClient _api = ApiClient();

  // GET /api/books
  Future<List<Book>> getBooks() async {
    final data = await _api.get('/books');

    // Accepts a plain list, or a Laravel page like {"data": [...]}
    final list = data is Map<String, dynamic> ? data['data'] : data;

    return (list as List)
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // GET /api/books/{id}
  Future<Book> getBook(int id) async {
    final data = await _api.get('/books/$id');
    return Book.fromJson(_bookMap(data));
  }

  // POST /api/books
  Future<Book> createBook({
    required String title,
    required String author,
    String? genre,
    String? description,
    required String status,
    required int totalPages,
    required int currentPage,
    File? poster,
  }) async {
    final fields = _fields(
      title: title,
      author: author,
      genre: genre,
      description: description,
      status: status,
      totalPages: totalPages,
      currentPage: currentPage,
    );

    final data = await _api.postMultipart('/books', fields, file: poster);
    return Book.fromJson(_bookMap(data));
  }

  // PUT /api/books/{id} (sent as POST + "_method=PUT", see the notes below)
  Future<Book> updateBook(
    int id, {
    required String title,
    required String author,
    String? genre,
    String? description,
    required String status,
    required int totalPages,
    required int currentPage,
    File? poster,
  }) async {
    final fields = _fields(
      title: title,
      author: author,
      genre: genre,
      description: description,
      status: status,
      totalPages: totalPages,
      currentPage: currentPage,
    )..['_method'] = 'PUT';

    final data = await _api.postMultipart('/books/$id', fields, file: poster);
    return Book.fromJson(_bookMap(data));
  }

  // DELETE /api/books/{id}
  Future<void> deleteBook(int id) async {
    await _api.delete('/books/$id');
  }

  // Form fields are always text. Empty genre/description are sent as '' so
  // Laravel turns them into null and clears the old value.
  Map<String, String> _fields({
    required String title,
    required String author,
    String? genre,
    String? description,
    required String status,
    required int totalPages,
    required int currentPage,
  }) {
    return {
      'title': title,
      'author': author,
      'genre': genre ?? '',
      'description': description ?? '',
      'status': status,
      'total_pages': totalPages.toString(),
      'current_page': currentPage.toString(),
    };
  }

  // Finds the book object whether Laravel returned it directly
  // or wrapped as {"message": "...", "book": {...}}
  Map<String, dynamic> _bookMap(dynamic data) {
    final map = data as Map<String, dynamic>;
    final inner = map['book'] ?? map['data'];
    return (inner ?? map) as Map<String, dynamic>;
  }
}
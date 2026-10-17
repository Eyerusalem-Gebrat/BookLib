
import 'package:booklib_app/models/book.dart';
import 'package:booklib_app/services/api_client.dart';
import 'package:image_picker/image_picker.dart';

class BookService {
  final ApiClient _api = ApiClient();

  // GET /api/books
  Future<List<Book>> getBooks() async {
    final data = await _api.get('/books');

    // Accept a plain list or a Laravel response like {"data": [...]}
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
    XFile? poster,
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

    final data = await _api.postMultipart(
      '/books',
      fields,
      fileBytes: poster == null ? null : await poster.readAsBytes(),
      fileName: poster?.name,
    );

    return Book.fromJson(_bookMap(data));
  }

  // PUT /api/books/{id}, sent as POST + "_method=PUT"
  Future<Book> updateBook(
    int id, {
    required String title,
    required String author,
    String? genre,
    String? description,
    required String status,
    required int totalPages,
    required int currentPage,
    XFile? poster,
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

    final data = await _api.postMultipart(
      '/books/$id',
      fields,
      fileBytes: poster == null ? null : await poster.readAsBytes(),
      fileName: poster?.name,
    );

    return Book.fromJson(_bookMap(data));
  }

  // DELETE /api/books/{id}
  Future<void> deleteBook(int id) async {
    await _api.delete('/books/$id');
  }

  // Convert form values to text fields for Laravel.
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

  // Handle a direct book response or a wrapped response.
  Map<String, dynamic> _bookMap(dynamic data) {
    final map = data as Map<String, dynamic>;
    final inner = map['book'] ?? map['data'];
    return (inner ?? map) as Map<String, dynamic>;
  }
}

import 'package:booklib_app/config/api_config.dart';

class Book {
  final int id;
  final String title;
  final String author;
  final String? genre;
  final String? description;
  final String status;
  final int totalPages;
  final int currentPage;
  final String? posterPath;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.genre,
    this.description,
    required this.status,
    required this.totalPages,
    required this.currentPage,
    this.posterPath,
  });

  // Builds a Book from one JSON object of Laravel's /api/books response
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: _toInt(json['id']),
      title: json['title'] as String,
      author: json['author'] as String,
      genre: json['genre'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String,
      totalPages: _toInt(json['total_pages']),
      currentPage: _toInt(json['current_page']),
      posterPath: json['poster_path'] as String?,
    );
  }

  // Progress percent (same formula as the website)
  int get percent =>
      totalPages > 0 ? ((currentPage / totalPages) * 100).round() : 0;

  // Readable status text
  String get statusLabel => switch (status) {
        'want_to_read' => 'Want to Read',
        'reading' => 'Reading',
        'finished' => 'Finished',
        _ => status,
      };

  // Full poster URL, or null when the book has no poster
  String? get posterUrl {
    final path = posterPath;
    if (path == null) return null;
    return ApiConfig.posterUrl(path);
  }
}

// Accepts a number or a numeric string and always returns an int
int _toInt(dynamic value) =>
    value is int ? value : int.parse(value.toString());
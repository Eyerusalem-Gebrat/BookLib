import 'package:flutter/material.dart';
import 'package:booklib_app/config/app_theme.dart';
import 'package:booklib_app/models/book.dart';
import 'package:booklib_app/screens/book_create_screen.dart';
import 'package:booklib_app/screens/book_detail_screen.dart';
import 'package:booklib_app/screens/book_edit_screen.dart';
import 'package:booklib_app/screens/landing_screen.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/auth_service.dart';
import 'package:booklib_app/services/book_service.dart';

/// Screen 1: Real book dashboard / reading list matching index.tsx
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  final AuthService _authService = AuthService();

  List<Book>? _books;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await _bookService.getBooks();
      if (!mounted) return;
      setState(() {
        _books = list;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (e.isUnauthorized) return;
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load your reading list. Check your connection.';
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => const BookCreateScreen()),
    );

    if (created == true) {
      _loadBooks();
    }
  }

  Future<void> _openDetail(Book book) async {
    final changed = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    );

    if (changed == true) {
      _loadBooks();
    }
  }

  Future<void> _openEdit(Book book) async {
    final updated = await Navigator.of(context).push<Book?>(
      MaterialPageRoute(builder: (_) => BookEditScreen(book: book)),
    );

    if (updated != null) {
      _loadBooks();
    }
  }

  Future<void> _confirmDelete(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Book',
          style: TextStyle(
            fontFamily: AppTheme.fontSerif,
            fontWeight: FontWeight.bold,
            color: AppTheme.text,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${book.title}"?',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB9382E),
              shape: const StadiumBorder(),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _bookService.deleteBook(book.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${book.title}"'),
          backgroundColor: AppTheme.primary,
        ),
      );
      _loadBooks();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFB9382E)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete book.'),
          backgroundColor: Color(0xFFB9382E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: AppTheme.headerBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'BookLib',
          style: TextStyle(
            fontFamily: AppTheme.fontSerif,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.headerLogo,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.btnCardBg,
                  border: Border.all(color: AppTheme.btnCardBorder),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.btnCardText,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.headerBorder),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBooks,
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardBg,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section matching index.tsx
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• PERSONAL LIBRARY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppTheme.kicker,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'My Reading List',
                        style: TextStyle(
                          fontFamily: AppTheme.fontSerif,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text,
                        ),
                      ),
                    ],
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [AppTheme.primaryGlow],
                    ),
                    child: FilledButton(
                      onPressed: _openCreate,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: 4),
                          Text('Add Book', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content State
              if (_loading) ...[
                const SizedBox(height: 80),
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 80),
              ] else if (_error != null) ...[
                _buildErrorState(),
              ] else if (_books == null || _books!.isEmpty) ...[
                _buildEmptyState(),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _books!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (ctx, i) => _buildBookCard(_books![i]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppTheme.badgeIconBg,
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('📖', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 16),
          const Text(
            "You haven't added any books yet.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _openCreate,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: const StadiumBorder(),
            ),
            child: const Text('Add your first book'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 40, color: Color(0xFFB9382E)),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadBooks,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: const StadiumBorder(),
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return InkWell(
      onTap: () => _openDetail(book),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Cover
            Container(
              width: 100,
              height: 145,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF2DBCB)),
                boxShadow: const [AppTheme.shadowSm],
              ),
              clipBehavior: Clip.antiAlias,
              child: book.posterUrl != null
                  ? Image.network(
                      book.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildEmptyPoster(),
                    )
                  : _buildEmptyPoster(),
            ),
            const SizedBox(width: 16),

            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontSerif,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(book.status, book.statusLabel),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Author
                  Text(
                    'by ${book.author}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Genre tag
                  if (book.genre != null && book.genre!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentLight,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'Genre: ${book.genre!}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Progress Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceInset,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.text,
                              ),
                            ),
                            Text(
                              '${book.percent}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.kicker,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: LinearProgressIndicator(
                            value: book.totalPages > 0
                                ? (book.currentPage / book.totalPages).clamp(0.0, 1.0)
                                : 0.0,
                            backgroundColor: AppTheme.progressTrack,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            minHeight: 5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${book.currentPage} / ${book.totalPages} pages (${book.percent}%)',
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),

                  // Actions: Edit and Delete
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _openEdit(book),
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.btnCardBg,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined, size: 13, color: AppTheme.btnCardText),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.btnCardText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _confirmDelete(book),
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECEB),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 13, color: Color(0xFFB9382E)),
                              SizedBox(width: 4),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB9382E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPoster() {
    return Container(
      color: AppTheme.badgeIconBg,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📖', style: TextStyle(fontSize: 22)),
            SizedBox(height: 4),
            Text(
              'NO POSTER',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: Color(0xFF7D614E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color bg;
    Color text;
    Color border;

    switch (status) {
      case 'reading':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFF92400E);
        border = const Color(0xFFFDE68A);
      case 'finished':
        bg = const Color(0xFFE3EDE2);
        text = const Color(0xFF234E38);
        border = const Color(0xFFC6DEC5);
      case 'want_to_read':
      default:
        bg = AppTheme.accentLight;
        text = AppTheme.kicker;
        border = AppTheme.statusWantBorder;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: text, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
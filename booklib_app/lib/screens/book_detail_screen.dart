import 'package:flutter/material.dart';
import 'package:booklib_app/config/app_theme.dart';
import 'package:booklib_app/models/book.dart';
import 'package:booklib_app/screens/book_edit_screen.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/book_service.dart';

/// Screen 2: Book details screen matching the website's show.tsx page
class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _book;
  final BookService _bookService = BookService();
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
  }

  Future<void> _refreshBook() async {
    try {
      final updated = await _bookService.getBook(_book.id);
      if (mounted) {
        setState(() => _book = updated);
      }
    } catch (_) {
      // Keep current data if fetch fails
    }
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<Book?>(
      MaterialPageRoute(builder: (_) => BookEditScreen(book: _book)),
    );

    if (updated != null && mounted) {
      setState(() => _book = updated);
    } else {
      _refreshBook();
    }
  }

  Future<void> _confirmDelete() async {
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
          'Are you sure you want to delete "${_book.title}"?',
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

    setState(() => _deleting = true);

    try {
      await _bookService.deleteBook(_book.id);
      if (!mounted) return;
      // Pop back to dashboard and signal refresh
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFB9382E)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete book. Please try again.'),
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
        leadingWidth: 105,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.btnCardBg,
                  border: Border.all(color: AppTheme.btnCardBorder),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: const [AppTheme.shadowSm],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 15,
                      color: AppTheme.btnCardText,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.btnCardText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'BookLib',
          style: TextStyle(
            fontFamily: AppTheme.fontSerif,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.headerLogo,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.headerBorder),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Book Poster
                Center(
                  child: Container(
                    width: 180,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF2DBCB)),
                      boxShadow: const [AppTheme.shadowSm],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _book.posterUrl != null
                        ? Image.network(
                            _book.posterUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildEmptyPoster(),
                          )
                        : _buildEmptyPoster(),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  _book.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontSerif,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),

                // Author
                Text(
                  'by ${_book.author}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                // Genre pill if available
                if (_book.genre != null && _book.genre!.trim().isNotEmpty) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentLight,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'Genre: ${_book.genre!}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Status Badge
                Center(child: _buildStatusBadge(_book.status, _book.statusLabel)),
                const SizedBox(height: 20),

                // Progress Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceInset,
                    borderRadius: BorderRadius.circular(14),
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
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.text,
                            ),
                          ),
                          Text(
                            '${_book.percent}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.kicker,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: LinearProgressIndicator(
                          value: _book.totalPages > 0
                              ? (_book.currentPage / _book.totalPages).clamp(0.0, 1.0)
                              : 0.0,
                          backgroundColor: AppTheme.progressTrack,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          minHeight: 7,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_book.currentPage} / ${_book.totalPages} pages (${_book.percent}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Description Box
                if (_book.description != null && _book.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceInset,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.inputBorder),
                    ),
                    child: Text(
                      _book.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: AppTheme.text,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 26),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _deleting ? null : _openEdit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, size: 16),
                            SizedBox(width: 6),
                            Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _deleting ? null : _confirmDelete,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFDECEB),
                          foregroundColor: const Color(0xFFB9382E),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: _deleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Color(0xFFB9382E)),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_outline_rounded, size: 16),
                                  SizedBox(width: 6),
                                  Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
            Text('📖', style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text(
              'NO POSTER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: text, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:booklib_app/config/app_theme.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/book_service.dart';
import 'package:booklib_app/services/poster_picker.dart';

/// Screen 3: Create book form matching website's create.tsx page
class BookCreateScreen extends StatefulWidget {
  const BookCreateScreen({super.key});

  @override
  State<BookCreateScreen> createState() => _BookCreateScreenState();
}

class _BookCreateScreenState extends State<BookCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _currentPageController = TextEditingController(text: '0');

  String _status = 'want_to_read';
  File? _poster;
  bool _saving = false;
  String? _error;
  final BookService _bookService = BookService();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primary),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final file = await PosterPicker.pick(source);
      if (file != null && mounted) {
        setState(() => _poster = file);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFB9382E)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image.'),
          backgroundColor: Color(0xFFB9382E),
        ),
      );
    }
  }

  void _onStatusChanged(String? newStatus) {
    if (newStatus == null) return;
    setState(() {
      _status = newStatus;
      if (newStatus == 'finished' && _totalPagesController.text.isNotEmpty) {
        _currentPageController.text = _totalPagesController.text;
      }
    });
  }

  void _onCurrentPageChanged(String value) {
    final total = int.tryParse(_totalPagesController.text) ?? 0;
    final current = int.tryParse(value);

    if (total > 0 && current != null && current >= total) {
      setState(() => _status = 'finished');
    } else if (_status == 'finished') {
      setState(() => _status = 'reading');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final totalPages = int.tryParse(_totalPagesController.text.trim()) ?? 0;
    final currentPage = int.tryParse(_currentPageController.text.trim()) ?? 0;

    if (totalPages < 1) {
      setState(() => _error = 'Total pages must be at least 1.');
      return;
    }

    if (currentPage < 0) {
      setState(() => _error = 'Pages read cannot be negative.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _bookService.createBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        genre: _genreController.text.trim().isEmpty
            ? null
            : _genreController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _status,
        totalPages: totalPages,
        currentPage: currentPage,
        poster: _poster,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Failed to create book. Please try again.';
      });
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
          child: Form(
            key: _formKey,
            child: Container(
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
                  // Kicker
                  const Text(
                    '• LIBRARY CATALOG',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppTheme.kicker,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Heading
                  const Text(
                    'Add a New Book',
                    style: TextStyle(
                      fontFamily: AppTheme.fontSerif,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  const Text(
                    'Fill in the book details to expand your personal collection and reading tracker.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEB),
                        border: Border.all(color: const Color(0xFFF8CFCB)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text('⚠  ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Color(0xFFB9382E),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Title with Required Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentLight,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.kicker,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'e.g., The Midnight Library'),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 18),

                  // Author
                  const Text(
                    'Author',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _authorController,
                    decoration: const InputDecoration(hintText: 'e.g., Matt Haig'),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Author is required' : null,
                  ),
                  const SizedBox(height: 18),

                  // Genre
                  const Text(
                    'Genre',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _genreController,
                    decoration: const InputDecoration(hintText: 'e.g., Fiction, Philosophy, Sci-Fi'),
                  ),
                  const SizedBox(height: 18),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write a brief summary or key impressions...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Poster
                  const Text(
                    'Poster',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_poster != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_poster!, height: 120, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: InkWell(
                              onTap: () => setState(() => _poster = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceInset,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.inputBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _poster != null
                                ? _poster!.path.split(Platform.pathSeparator).last
                                : 'No file chosen\nPNG, JPG, WEBP up to 2MB',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2623),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: const Text(
                              'Choose File',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Status
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _status,
                    dropdownColor: AppTheme.cardBg,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                    items: const [
                      DropdownMenuItem(value: 'want_to_read', child: Text('Want to Read')),
                      DropdownMenuItem(value: 'reading', child: Text('Reading')),
                      DropdownMenuItem(value: 'finished', child: Text('Finished')),
                    ],
                    onChanged: _onStatusChanged,
                  ),
                  const SizedBox(height: 18),

                  // Total pages and Pages read
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total pages',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _totalPagesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: 'e.g., 304'),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required';
                                }
                                final n = int.tryParse(val);
                                if (n == null || n < 1) return 'Must be >= 1';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pages read',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _currentPageController,
                              keyboardType: TextInputType.number,
                              onChanged: _onCurrentPageChanged,
                              decoration: const InputDecoration(hintText: '0'),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required';
                                }
                                final n = int.tryParse(val);
                                if (n == null || n < 0) return 'Must be >= 0';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons: Cancel (Peach) + Save Book (Terracotta)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: _saving ? null : () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: AppTheme.btnCardBg,
                              border: Border.all(color: AppTheme.btnCardBorder),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.btnCardText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: FilledButton(
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Save Book',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
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
      ),
    );
  }
}

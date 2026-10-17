import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:booklib_app/config/app_theme.dart';
import 'package:booklib_app/models/book.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/book_service.dart';

/// Screen 4: Edit book form matching website's edit.tsx page.
class BookEditScreen extends StatefulWidget {
  final Book book;

  const BookEditScreen({super.key, required this.book});

  @override
  State<BookEditScreen> createState() => _BookEditScreenState();
}

class _BookEditScreenState extends State<BookEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _genreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _totalPagesController;
  late final TextEditingController _currentPageController;

  final BookService _bookService = BookService();
  final ImagePicker _imagePicker = ImagePicker();

  late String _status;
  XFile? _newPoster;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _genreController =
        TextEditingController(text: widget.book.genre ?? '');
    _descriptionController =
        TextEditingController(text: widget.book.description ?? '');
    _totalPagesController =
        TextEditingController(text: widget.book.totalPages.toString());
    _currentPageController =
        TextEditingController(text: widget.book.currentPage.toString());

    _status = widget.book.status;
  }

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
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppTheme.primary,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppTheme.primary,
                ),
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
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedImage == null) return;

      const maxBytes = 2 * 1024 * 1024;

      if (await pickedImage.length() > maxBytes) {
        throw const ApiException(
          'The image is larger than 2 MB. Please choose a smaller one.',
        );
      }

      if (!mounted) return;

      setState(() {
        _newPoster = pickedImage;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFB9382E),
        ),
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

      if (newStatus == 'finished' &&
          _totalPagesController.text.isNotEmpty) {
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

    final totalPages =
        int.tryParse(_totalPagesController.text.trim()) ?? 0;
    final currentPage =
        int.tryParse(_currentPageController.text.trim()) ?? 0;

    if (totalPages < 1) {
      setState(() => _error = 'Total pages must be at least 1.');
      return;
    }

    if (currentPage < 0) {
      setState(() => _error = 'Pages read cannot be negative.');
      return;
    }

    if (currentPage > totalPages) {
      setState(() => _error = 'Pages read cannot exceed total pages.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final updated = await _bookService.updateBook(
        widget.book.id,
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
        poster: _newPoster,
      );

      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = 'Failed to update book. Please try again.';
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
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
                  const Text(
                    'Edit Book',
                    style: TextStyle(
                      fontFamily: AppTheme.fontSerif,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEB),
                        border: Border.all(
                          color: const Color(0xFFF8CFCB),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '⚠  ',
                            style: TextStyle(fontSize: 14),
                          ),
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

                  const Text(
                    'Title',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Atomic Habits',
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty)
                            ? 'Title is required'
                            : null,
                  ),
                  const SizedBox(height: 18),

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
                    decoration: const InputDecoration(
                      hintText: 'e.g. James Clear',
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty)
                            ? 'Author is required'
                            : null,
                  ),
                  const SizedBox(height: 18),

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
                    decoration: const InputDecoration(
                      hintText: 'e.g. Self-Help, Fiction',
                    ),
                  ),
                  const SizedBox(height: 18),

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
                      hintText:
                          'Enter synopsis or personal notes on this volume...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppTheme.inputBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppTheme.inputBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Change poster',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Preview the newly selected poster.
                  if (_newPoster != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FutureBuilder<Uint8List>(
                              future: _newPoster!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  );
                                }

                                if (snapshot.hasError) {
                                  return const SizedBox(
                                    height: 120,
                                    width: 90,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                      ),
                                    ),
                                  );
                                }

                                return const SizedBox(
                                  height: 120,
                                  width: 90,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() => _newPoster = null);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  // Show the current poster when no replacement is selected.
                  else if (widget.book.posterUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.book.posterUrl!,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                            _newPoster != null
                                ? _newPoster!.name
                                : (widget.book.posterPath != null
                                    ? 'Current poster kept'
                                    : 'No file chosen'),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
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
                    initialValue: _status,
                    dropdownColor: AppTheme.cardBg,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'want_to_read',
                        child: Text('Want to Read'),
                      ),
                      DropdownMenuItem(
                        value: 'reading',
                        child: Text('Reading'),
                      ),
                      DropdownMenuItem(
                        value: 'finished',
                        child: Text('Finished'),
                      ),
                    ],
                    onChanged: _onStatusChanged,
                  ),
                  const SizedBox(height: 18),

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
                              decoration: const InputDecoration(
                                hintText: 'e.g. 304',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required';
                                }

                                final n = int.tryParse(val);
                                if (n == null || n < 1) {
                                  return 'Must be >= 1';
                                }

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
                              decoration: const InputDecoration(
                                hintText: '0',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required';
                                }

                                final n = int.tryParse(val);
                                if (n == null || n < 0) {
                                  return 'Must be >= 0';
                                }

                                final total = int.tryParse(
                                      _totalPagesController.text.trim(),
                                    ) ??
                                    0;

                                if (n > total) {
                                  return 'Cannot exceed total';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: FilledButton(
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: _saving
                              ? null
                              : () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: AppTheme.btnCardBg,
                              border: Border.all(
                                color: AppTheme.btnCardBorder,
                              ),
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
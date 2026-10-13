import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:booklib_app/services/api_exception.dart';

// Lets the user choose a poster image and checks it before it is uploaded
class PosterPicker {
  PosterPicker._();

  // The server allows up to 2 MB (the rule "max:2048")
  static const int maxBytes = 2 * 1024 * 1024;

  static final ImagePicker _picker = ImagePicker();

  // Returns the chosen image, or null if the user cancelled
  static Future<File?> pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200, // shrink big photos before uploading
      maxHeight: 1800,
      imageQuality: 85, // compress a little
    );

    if (picked == null) return null; // the user closed the picker

    final file = File(picked.path);

    if (await file.length() > maxBytes) {
      throw const ApiException(
        'The image is larger than 2 MB. Please choose a smaller one.',
      );
    }

    return file;
  }
}
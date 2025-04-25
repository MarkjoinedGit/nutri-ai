import 'dart:io';
import 'package:mime/mime.dart';

// Extension to check if a File is a valid image
extension FileExtension on File {
  bool get isValidImage {
    final mimeType = lookupMimeType(path);
    return mimeType != null && mimeType.startsWith('image/');
  }
}
import 'dart:io';
import 'package:mime/mime.dart';

extension FileExtension on File {
  bool get isValidImage {
    final mimeType = lookupMimeType(path);
    return mimeType != null && mimeType.startsWith('image/');
  }
}
import 'package:http_parser/http_parser.dart';

// Extension method to parse MIME type string to MediaType object
extension on String {
  MediaType toMediaType() {
    final parts = split('/');
    if (parts.length != 2) {
      throw FormatException('Invalid MIME type: $this');
    }
    return MediaType(parts[0], parts[1]);
  }
}

// Helper function to parse MIME types
MediaType parse(String mimeType) {
  return mimeType.toMediaType();
}
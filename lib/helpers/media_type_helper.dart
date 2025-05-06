import 'package:http_parser/http_parser.dart';

extension on String {
  MediaType toMediaType() {
    final parts = split('/');
    if (parts.length != 2) {
      throw FormatException('Invalid MIME type: $this');
    }
    return MediaType(parts[0], parts[1]);
  }
}

MediaType parse(String mimeType) {
  return mimeType.toMediaType();
}
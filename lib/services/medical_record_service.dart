import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/medical_record_model.dart';
import '../config/api_config.dart';

class MedicalRecordService {
  final String baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách hồ sơ y tế của người dùng
  Future<List<MedicalRecord>> fetchMedicalRecords(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/MedicalRecords/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> recordsJson = jsonDecode(response.body);
      return recordsJson.map((json) => MedicalRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medical records: ${response.statusCode}');
    }
  }

  // Upload hồ sơ y tế kèm ảnh
  Future<MedicalRecord> uploadMedicalRecord(File image, String userId) async {
    try {
      final mimeType = lookupMimeType(image.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception('The selected file is not a valid image.');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/MedicalRecords/create'),
      );

      request.fields['id_user'] = userId;

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final recordJson = jsonDecode(response.body);
        return MedicalRecord.fromJson(recordJson);
      } else {
        Map<String, dynamic> errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['error'] ?? 'Failed to upload medical record.');
      }
    } catch (e) {
      throw Exception('Error uploading medical record: ${e.toString()}');
    }
  }

  // Cập nhật hồ sơ y tế
  Future<MedicalRecord> updateMedicalRecord(MedicalRecord record) async {
    final response = await http.put(
      Uri.parse('$baseUrl/MedicalRecords/update/${record.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(record.toJson()),
    );

    if (response.statusCode == 200) {
      final updatedRecordJson = jsonDecode(response.body);
      return MedicalRecord.fromJson(updatedRecordJson);
    } else {
      throw Exception('Failed to update medical record: ${response.statusCode}');
    }
  }
}

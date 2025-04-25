import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../models/nutrition_info_model.dart';
import '../config/api_config.dart';
import 'package:http_parser/http_parser.dart';

class RecipeService {
  final String baseUrl = ApiConfig.baseUrl;

  // Get nutrition information from image
  Future<NutritionInfo> getNutritionInfo(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/features/NutriCalorie'),
      );

      // Detect MIME type of the image
      final mimeType = lookupMimeType(image.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception('The selected file is not a valid image.');
      }

      // Add image file to request with proper content type
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // Parse response with UTF-8 encoding
        Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return NutritionInfo.fromJson(data);
      } else {
        Map<String, dynamic> errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['error'] ?? 'Unable to retrieve nutrition information.');
      }
    } catch (e) {
      throw Exception('Error analyzing food image: ${e.toString()}');
    }
  }

  // Get recipe from image
  Future<String> getRecipe(File image, String userId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/features/NutriRecipes'),
      );

      // Detect MIME type of the image
      final mimeType = lookupMimeType(image.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception('The selected file is not a valid image.');
      }

      // Add user ID
      request.fields['id_user'] = userId;

      // Add image file to request with proper content type
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // Parse response with UTF-8 encoding
        Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data['result'] ?? '';
      } else {
        Map<String, dynamic> errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['error'] ?? 'Failed to generate recipe.');
      }
    } catch (e) {
      throw Exception('Error generating recipe: ${e.toString()}');
    }
  }
}
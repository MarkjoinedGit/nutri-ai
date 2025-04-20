import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Replace with your actual API URL
  final String baseUrl = 'https://zep.hcmute.fit/7800'; // For Android emulator
  // Use 'http://localhost:8000' for iOS simulator or web

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    bool isDoctor,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'isDoctor': isDoctor,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'userId': data['id'] ?? '',
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error occurred');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'userId': data['user']['_id'] ?? '',
          'name': data['user']['name'] ?? '',
          'email': data['user']['email'] ?? '',
          'isDoctor': data['user']['isDoctor'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error occurred');
    }
  }

  Future<bool> logout(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          '_id': userId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
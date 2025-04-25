import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../config/api_config.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<User> register(
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
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return User(
          id: data['id'] ?? '',
          name: name,
          email: email,
          isDoctor: isDoctor,
        );
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(error['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error occurred');
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return User(
          id: data['user']['_id'] ?? '',
          name: data['user']['name'] ?? '',
          email: data['user']['email'] ?? '',
          isDoctor: data['user']['isDoctor'] ?? false,
        );
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
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
        body: jsonEncode({'_id': userId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_auth_service.dart';
import '../models/news_article.dart';

class ApiNewsService {
  final String baseUrl = ApiAuthService.baseUrl;
  final ApiAuthService _authService = ApiAuthService();

  // Helper to get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/news - Fetch all articles
  Future<List<NewsArticle>> getNews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/news'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articlesJson = data['data'] ?? []; // Adjust based on actual API response structure
        return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET /api/news/categories - Fetch categories
  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/news/categories'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // Return default categories on error to keep UI functional
      return ['All', 'Events', 'Academic', 'Maintenance', 'Sports'];
    }
  }

  // GET /api/news/:id - Get single article
  Future<NewsArticle> getArticle(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/news/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NewsArticle.fromJson(data['data']);
      } else {
        throw Exception('Failed to load article');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

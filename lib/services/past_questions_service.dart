import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'api_auth_service.dart';

class PastQuestionsService {
  static const String baseUrl = 'https://backend-proj-50kp.onrender.com';
  final ApiAuthService _authService = ApiAuthService();

  // Helper for authenticated requests
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /api/past-questions - Fetch all past questions (with optional filters)
  Future<Map<String, dynamic>> fetchPastQuestions({
    String? course,
    String? semester,
    String? level,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (course != null) queryParams['course'] = course;
      if (semester != null) queryParams['semester'] = semester;
      if (level != null) queryParams['level'] = level;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/api/past-questions')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data['questions'] ?? data,
          'pagination': data['pagination'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to fetch questions'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // GET /api/past-questions/:id - Get single past question
  Future<Map<String, dynamic>> getPastQuestion(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/past-questions/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'question': data['data'] ?? data['question'] ?? data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Question not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // POST /api/past-questions/upload - Upload a new past question
  Future<Map<String, dynamic>> uploadPastQuestion({
    required File file,
    required String title,
    required String courseName,
    required String courseCode,
    required String semester,
    required String level,
    List<String>? tags,
    bool isPaid = false,
    double? price,
  }) async {
    try {
      final token = await _authService.getAuthToken();
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/past-questions/upload'),
      );

      // Add auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Add fields
      request.fields['title'] = title;
      request.fields['courseName'] = courseName;
      request.fields['courseCode'] = courseCode;
      request.fields['semester'] = semester;
      request.fields['level'] = level;
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = jsonEncode(tags);
      }
      request.fields['isPaid'] = isPaid.toString();
      if (isPaid && price != null) {
        request.fields['price'] = price.toString();
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Uploaded successfully',
          'data': data['data'] ?? data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Upload failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // POST /api/past-questions/:id/download - Download/purchase a past question
  Future<Map<String, dynamic>> downloadPastQuestion(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/past-questions/$id/download'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'downloadUrl': data['downloadUrl'] ?? data['url'],
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Download failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // POST /api/past-questions/:id/rate - Rate a past question
  Future<Map<String, dynamic>> ratePastQuestion(String id, int rating) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/past-questions/$id/rate'),
        headers: headers,
        body: jsonEncode({'rating': rating}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': 'Rating submitted', 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Rating failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // GET /api/past-questions/user/my-uploads - Get user's uploaded questions
  Future<Map<String, dynamic>> getMyUploads() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/past-questions/user/my-uploads'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'uploads': data['data'] ?? data['uploads'] ?? data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to fetch uploads'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiNotificationService {
  final String baseUrl = 'https://backend-proj-50kp.onrender.com';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /api/notifications
  Future<List<dynamic>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Assuming body['data'] contains the list or body itself is the list
        if (body is Map && body.containsKey('data')) {
          return body['data'];
        } else if (body is List) {
          return body;
        } else if (body is Map && body.containsKey('notifications')) {
           return body['notifications'];
        }
        return [];
      } else {
        print('Failed to load notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  // GET /api/notifications/unread-count
  Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/unread-count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('count')) {
          return body['count'];
        } else if (body is Map && body.containsKey('unread')) {
          return body['unread'];
        } else if (body is int) {
           return body;
        }
        return 0;
      }
      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // PUT /api/notifications/read-all
  Future<bool> markAllRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/read-all'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all read: $e');
      return false;
    }
  }

  // DELETE /api/notifications/clear-all
  Future<bool> clearAll() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/clear-all'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing all: $e');
      return false;
    }
  }

  // PUT /api/notifications/:id/read
  Future<bool> markAsRead(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$id/read'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking read: $e');
      return false;
    }
  }

  // DELETE /api/notifications/:id
  Future<bool> deleteNotification(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/$id'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
}

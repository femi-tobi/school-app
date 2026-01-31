import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuthService {
  // TODO: Replace with your actual API base URL
  static const String baseUrl = 'https://backend-proj-50kp.onrender.com';
  
  // Store user session
  Future<void> _saveUserSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user));
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Register with email and password
  Future<Map<String, dynamic>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': fullName,
          // student_id not used by backend, omitted
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveUserSession(data['token'], data['user']);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Handle nested data structure: {success, message, data: {user, accessToken, refreshToken}}
        final data = responseData['data'];
        
        if (data == null) {
          print('No data field in response');
          return {'success': false, 'message': 'Invalid response format'};
        }
        
        // Token is inside data.accessToken
        final token = data['accessToken'] ?? data['token'] ?? data['access_token'];
        final user = data['user'];
        
        if (token == null) {
          print('Available fields in data: ${data.keys}');
          return {'success': false, 'message': 'No token received from server'};
        }
        
        print('Token found: ${token.substring(0, 20)}...');
        await _saveUserSession(token, user ?? {});
        return {'success': true, 'data': responseData};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _clearUserSession();
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password reset email sent'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Reset failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Helper for authenticated requests
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /api/auth/me - Get current user from API
  Future<Map<String, dynamic>> fetchCurrentUser() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var user = responseData['data'] ?? responseData['user'] ?? responseData;
        
        // Unwrap if user object is nested (e.g. data: { user: {...} })
        if (user is Map && user.containsKey('user')) {
          user = user['user'];
        }
        
        // Update local storage with fresh user data
        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(user));
        }
        
        return {'success': true, 'user': user};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to fetch user'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // POST /api/auth/logout - Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: headers,
      );

      // Clear local session regardless of API response
      await _clearUserSession();

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        // Still return success since local session is cleared
        return {'success': true, 'message': 'Logged out locally'};
      }
    } catch (e) {
      // Still clear local session on error
      await _clearUserSession();
      return {'success': true, 'message': 'Logged out locally'};
    }
  }

  // POST /api/auth/refresh-token - Refresh access token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] ?? responseData;
        final newToken = data['accessToken'] ?? data['token'];
        
        if (newToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', newToken);
        }
        
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Token refresh failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // PUT /api/auth/profile - Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? university,
    String? department,
    String? level,
    String? avatar,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      // Build update payload with only non-null fields
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (university != null) updateData['university'] = university;
      if (department != null) updateData['department'] = department;
      if (level != null) updateData['level'] = level;
      if (avatar != null) updateData['avatar'] = avatar;

      final response = await http.put(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = responseData['data'] ?? responseData['user'] ?? responseData;
        
        // Update local storage
        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(user));
        }
        
        return {'success': true, 'user': user, 'message': 'Profile updated'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Update failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // PUT /api/auth/change-password - Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/auth/change-password'),
        headers: headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Password change failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

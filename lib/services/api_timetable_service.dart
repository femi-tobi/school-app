import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/timetable_class.dart';
import 'api_auth_service.dart';

class ApiTimetableService {
  final String baseUrl = ApiAuthService.baseUrl;
  final ApiAuthService _authService = ApiAuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get timetable for a specific day or all days
  Future<Map<int, List<TimetableClass>>> getTimetable() async {
    try {
      // TODO: Replace with actual endpoint when available on backend
      // For now we will return some mock data but simulated as an API call
      // In a real app, this would be:
      /*
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/timetable'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // data processing to Map<int, List<TimetableClass>>
      }
      */
      
      // Simulating network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data response
      return {
        2: [ // Wednesday
          TimetableClass(
            courseCode: 'PHY 101',
            courseName: 'General Physics',
            startTime: '08:00 AM',
            endTime: '10:00 AM',
            location: 'Hall A',
            professor: 'Prof. A.S. Okoro',
            iconName: 'science',
            accentColor: 'primary',
          ),
          TimetableClass(
            courseCode: 'MAT 102',
            courseName: 'Calculus II',
            startTime: '12:00 PM',
            endTime: '02:00 PM',
            location: 'CBT Centre',
            professor: 'Dr. J.O. Mensah',
            iconName: 'calculate',
            accentColor: 'emerald',
          ),
          TimetableClass(
            courseCode: 'CHM 101',
            courseName: 'General Chemistry',
            startTime: '03:00 PM',
            endTime: '05:00 PM',
            location: 'Lab 2',
            professor: 'Dr. B.K. Abiola',
            iconName: 'science',
            accentColor: 'amber',
          ),
        ],
        // Other days can be added here
      };
    } catch (e) {
      throw Exception('Failed to load timetable: $e');
    }
  }

  Future<bool> addTimetableEntry(TimetableClass entry) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/timetable'),
        headers: headers,
        body: jsonEncode(entry.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

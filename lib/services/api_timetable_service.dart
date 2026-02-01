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

  // Get full timetable
  Future<Map<int, List<TimetableClass>>> getTimetable() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/timetable'),
        headers: headers,
      );

      print('Get Timetable Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<int, List<TimetableClass>> timetable = {};
        
        // Handle response structure logic based on API return
        // Assuming API returns a list of classes or a map keyed by dayIndex
        if (data is List) {
          for (var item in data) {
            final entry = TimetableClass.fromJson(item);
            if (!timetable.containsKey(entry.dayIndex)) {
              timetable[entry.dayIndex] = [];
            }
            timetable[entry.dayIndex]!.add(entry);
          }
        } else if (data is Map) {
             // Handle if keys are day indices
             data.forEach((key, value) {
               final dayIdx = int.tryParse(key.toString()) ?? 0;
               if (value is List) {
                 timetable[dayIdx] = value.map((e) => TimetableClass.fromJson(e)).toList();
               }
             });
        }
        
        return timetable;
      }
      return {};
    } catch (e) {
      print('Error fetching timetable: $e');
      throw Exception('Failed to load timetable: $e');
    }
  }

  // Add a class
  Future<bool> addTimetableEntry(TimetableClass entry) async {
    print('Attempting to add timetable entry: ${jsonEncode(entry.toJson())}');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/timetable/class'),
        headers: headers,
        body: jsonEncode(entry.toJson()),
      );

      print('Add Class Response (${response.statusCode}): ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding timetable entry: $e');
      return false;
    }
  }
  
  // Update a class
  Future<bool> updateTimetableEntry(int dayIndex, int classIndex, TimetableClass entry) async {
     print('Attempting to update class at day $dayIndex index $classIndex');
     try {
       final headers = await _getHeaders();
       // Note: Using PUT /api/timetable/class/:dayIndex/:classIndex as requested
       final response = await http.put(
         Uri.parse('$baseUrl/api/timetable/class/$dayIndex/$classIndex'),
         headers: headers,
         body: jsonEncode(entry.toJson()),
       );

       print('Update Class Response (${response.statusCode}): ${response.body}');
       return response.statusCode == 200;
     } catch (e) {
       print('Error updating timetable entry: $e');
       return false;
     }
  }

  // Delete a class
  Future<bool> deleteTimetableEntry(int dayIndex, int classIndex) async {
    print('Attempting to delete class at day $dayIndex index $classIndex');
     try {
       final headers = await _getHeaders();
       final response = await http.delete(
         Uri.parse('$baseUrl/api/timetable/class/$dayIndex/$classIndex'),
         headers: headers,
       );

       print('Delete Class Response (${response.statusCode}): ${response.body}');
       return response.statusCode == 200;
     } catch (e) {
       print('Error deleting timetable entry: $e');
       return false;
     }
  }

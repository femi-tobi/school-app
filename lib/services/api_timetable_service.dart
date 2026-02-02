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
      print('Get Timetable Body: ${response.body}');
      
      if (response.statusCode == 200) {
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final Map<int, List<TimetableClass>> timetable = {};
        
        dynamic scheduleData;
        
        // Handle nested structure: body['data']['schedule']
        if (body is Map && body.containsKey('data') && body['data'] is Map && body['data'].containsKey('schedule')) {
          scheduleData = body['data']['schedule'];
        } else if (body is Map && body.containsKey('schedule')) {
          scheduleData = body['schedule'];
        } else {
          scheduleData = body; // Fallback to assuming root content
        }

        if (scheduleData is Map) {
             scheduleData.forEach((key, value) {
               final dayIdx = int.tryParse(key.toString()) ?? -1;
               if (dayIdx >= 0 && value is List) {
                 timetable[dayIdx] = value.map((e) => TimetableClass.fromJson(e)).toList();
               }
             });
        } else if (scheduleData is List) {
          for (var item in scheduleData) {
            final entry = TimetableClass.fromJson(item);
            if (!timetable.containsKey(entry.dayIndex)) {
              timetable[entry.dayIndex] = [];
            }
            timetable[entry.dayIndex]!.add(entry);
          }
        }
        
        return timetable;
      }
      }
      return {};
    } catch (e) {
      print('Error fetching timetable: $e');
      throw Exception('Failed to load timetable: $e');
    }
  }

  // Add a class
  Future<String?> addTimetableEntry(TimetableClass entry) async {
    print('Attempting to add timetable entry: ${jsonEncode(entry.toJson())}');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/timetable/class'), // Restored /class
        headers: headers,
        body: jsonEncode(entry.toJson()),
      );

      print('Add Class Response (${response.statusCode}): ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Success
      } else {
        return 'Failed (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      print('Error adding timetable entry: $e');
      return 'Error: $e';
    }
  }
  
  // Update a class
  Future<String?> updateTimetableEntry(int dayIndex, int classIndex, TimetableClass entry) async {
     print('Attempting to update class at day $dayIndex index $classIndex');
     try {
       final headers = await _getHeaders();
       final response = await http.put(
         Uri.parse('$baseUrl/api/timetable/class/$dayIndex/$classIndex'), // Restored /class
         headers: headers,
         body: jsonEncode(entry.toJson()),
       );

       print('Update Class Response (${response.statusCode}): ${response.body}');
       if (response.statusCode == 200) {
         return null; // Success
       } else {
         return 'Failed (${response.statusCode}): ${response.body}';
       }
     } catch (e) {
       print('Error updating timetable entry: $e');
       return 'Error: $e';
     }
  }

  // Delete a class
  Future<String?> deleteTimetableEntry(int dayIndex, int classIndex) async {
    print('Attempting to delete class at day $dayIndex index $classIndex');
     try {
       final headers = await _getHeaders();
       final response = await http.delete(
         Uri.parse('$baseUrl/api/timetable/class/$dayIndex/$classIndex'), // Restored /class
         headers: headers,
       );

       print('Delete Class Response (${response.statusCode}): ${response.body}');
       if (response.statusCode == 200) {
         return null; // Success
       } else {
         return 'Failed (${response.statusCode}): ${response.body}';
       }
     } catch (e) {
       print('Error deleting timetable entry: $e');
       return 'Error: $e';
     }
  }
}

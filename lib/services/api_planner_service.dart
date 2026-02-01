import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/study_session.dart';
import 'api_auth_service.dart';

class ApiPlannerService {
  final String baseUrl = ApiAuthService.baseUrl;
  final ApiAuthService _authService = ApiAuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<StudySession>> getStudySessions() async {
    try {
      // Simulating API call
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Mock data
      return [
        StudySession(
          courseCode: 'CS101',
          courseName: 'Data Structures',
          topic: 'Binary Search Trees',
          startTime: '14:00',
          endTime: '15:30',
          durationMinutes: 90,
          status: 'in_progress',
          imageUrl: 'https://picsum.photos/seed/planner1/400/400',
        ),
        StudySession(
          courseCode: 'ECON',
          courseName: 'Macro Trends',
          topic: 'Inflation & GDP',
          startTime: '16:00',
          endTime: '17:00',
          durationMinutes: 60,
          status: 'upcoming',
          imageUrl: 'https://picsum.photos/seed/planner2/400/400',
        ),
      ];
    } catch (e) {
      throw Exception('Failed to load study sessions: $e');
    }
  }

  Future<List<PastQuestion>> getPastQuestions() async {
    try {
       // Simulating API call
      await Future.delayed(const Duration(milliseconds: 1200));

      return [
        PastQuestion(
          title: '2023 Finals: Calculus II',
          subtitle: 'Not started • 12 Questions',
          icon: 'quiz',
          iconColor: 'orange',
        ),
        PastQuestion(
          title: 'Bio Lab Report: Genetics',
          subtitle: 'Completed yesterday',
          icon: 'description',
          iconColor: 'green',
          completed: true,
        ),
      ];
    } catch (e) {
      throw Exception('Failed to load past questions: $e');
    }
  }
}

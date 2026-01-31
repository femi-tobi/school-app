import 'package:flutter/material.dart';

class PastQuestionDocument {
  final String courseCode;
  final String courseName;
  final String category;
  final String session;
  final String uploadedBy;
  final bool isFree;
  final String iconName; // 'menu_book', 'calculate', 'biotech'
  final List<Color> gradientColors;

  PastQuestionDocument({
    required this.courseCode,
    required this.courseName,
    required this.category,
    required this.session,
    required this.uploadedBy,
    required this.isFree,
    required this.iconName,
    required this.gradientColors,
  });
}

class TimetableClass {
  final String courseCode;
  final String courseName;
  final String startTime;
  final String endTime;
  final String location;
  final String professor;
  final String iconName;
  final String accentColor; // 'primary', 'emerald', 'amber', etc.

  TimetableClass({
    required this.courseCode,
    required this.courseName,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.professor,
    required this.iconName,
    required this.accentColor,
  });
}

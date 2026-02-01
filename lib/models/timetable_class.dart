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

  factory TimetableClass.fromJson(Map<String, dynamic> json) {
    return TimetableClass(
      courseCode: json['courseCode'] ?? '',
      courseName: json['courseName'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      professor: json['professor'] ?? '',
      iconName: json['iconName'] ?? 'science',
      accentColor: json['accentColor'] ?? 'primary',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'professor': professor,
      'iconName': iconName,
      'accentColor': accentColor,
    };
  }
}

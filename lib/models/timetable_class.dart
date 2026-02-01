class TimetableClass {
  final String? id; // Optional ID from backend
  final int dayIndex;
  final String courseCode;
  final String courseName;
  final String startTime;
  final String endTime;
  final String location;
  final String professor;
  final String iconName;
  final String accentColor; // 'primary', 'emerald', 'amber', etc.

  TimetableClass({
    this.id,
    required this.dayIndex,
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
      id: json['id']?.toString() ?? json['_id']?.toString(),
      dayIndex: json['dayIndex'] is int ? json['dayIndex'] : int.tryParse(json['dayIndex'].toString()) ?? 0,
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
      if (id != null) 'id': id,
      'dayIndex': dayIndex,
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

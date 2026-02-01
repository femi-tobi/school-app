class StudySession {
  final String courseCode;
  final String courseName;
  final String topic;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String status; // 'in_progress', 'upcoming', 'completed'
  final String? imageUrl;

  StudySession({
    required this.courseCode,
    required this.courseName,
    required this.topic,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    this.imageUrl,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      courseCode: json['courseCode'] ?? '',
      courseName: json['courseName'] ?? '',
      topic: json['topic'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      status: json['status'] ?? 'upcoming',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'topic': topic,
      'startTime': startTime,
      'endTime': endTime,
      'durationMinutes': durationMinutes,
      'status': status,
      'imageUrl': imageUrl,
    };
  }
}

class PastQuestion {
  final String title;
  final String subtitle;
  final String icon; // 'quiz' or 'description'
  final String iconColor; // 'orange' or 'green'
  final bool completed;

  PastQuestion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.completed = false,
  });

  factory PastQuestion.fromJson(Map<String, dynamic> json) {
    return PastQuestion(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      icon: json['icon'] ?? 'description',
      iconColor: json['iconColor'] ?? 'green',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'icon': icon,
      'iconColor': iconColor,
      'completed': completed,
    };
  }
}

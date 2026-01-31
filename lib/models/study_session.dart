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
}

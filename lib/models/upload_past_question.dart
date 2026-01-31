class UploadPastQuestion {
  final String? filePath;
  final String courseName;
  final String semester;
  final String level;
  final List<String> tags;
  final bool isPaid;
  final int? price;

  UploadPastQuestion({
    this.filePath,
    required this.courseName,
    required this.semester,
    required this.level,
    this.tags = const [],
    this.isPaid = false,
    this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'courseName': courseName,
      'semester': semester,
      'level': level,
      'tags': tags,
      'isPaid': isPaid,
      'price': price,
    };
  }
}

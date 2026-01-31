import 'package:flutter/material.dart';

class NewsArticle {
  final String category;
  final String title;
  final String description;
  final String time;
  final String imageUrl;
  final Color categoryColor;

  NewsArticle({
    required this.category,
    required this.title,
    required this.description,
    required this.time,
    required this.imageUrl,
    this.categoryColor = Colors.blue, // Default color, will be mapped from category
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    String category = json['category'] ?? 'General';
    return NewsArticle(
      category: category,
      title: json['title'] ?? 'No Title',
      description: json['content'] ?? json['description'] ?? '',
      time: json['createdAt'] != null 
          ? _formatDate(json['createdAt']) 
          : 'Recently',
      imageUrl: json['imageUrl'] ?? json['image'] ?? 'https://picsum.photos/400/200',
      categoryColor: _getColorForCategory(category),
    );
  }

  static Color _getColorForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'EVENTS':
        return Colors.green;
      case 'MAINTENANCE':
        return Colors.orange;
      case 'ACADEMIC':
        return Colors.purple;
      case 'SPORTS':
        return Colors.red;
      case 'LIBRARY':
      case 'LIBRARY UPDATE':
        return const Color(0xFF0d59f2);
      default:
        return Colors.blue;
    }
  }

  static String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} mins ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }
}

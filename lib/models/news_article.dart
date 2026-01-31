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
    required this.categoryColor,
  });
}

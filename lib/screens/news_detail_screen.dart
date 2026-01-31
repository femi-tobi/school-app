import 'package:flutter/material.dart';
import '../models/news_article.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : Colors.white,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(article.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Article Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and Time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: article.categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              article.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: article.categoryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Oct 24, 2023 • 2 min read',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        article.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey.shade900,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Article Body
                      Text(
                        article.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                          height: 1.6,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const SizedBox(height: 8),
                      
                      // Schedule List
                      ...['Mon - Fri: 8:00 AM – 12:00 AM', 'Sat - Sun: 9:00 AM – 8:00 PM', 'Public Holidays: Closed'].map((item) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      
                      const SizedBox(height: 48),
                      
                      // Related News Section
                      Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Related News',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.grey.shade900,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0d59f2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Related News Items
                      _buildRelatedNewsItem(
                        'EVENTS',
                        'Registration for Inter-College Sports Fest Open',
                        'Yesterday',
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBdL_rDWQ3lAkSqWMm8dwQV-2J_KdGSS2Y6uhzzD1BMcfOtqXkvXAg-aiTY7WEX00yFQZ4JE-NUvEAYn20nObfAMaaZCU_Q-14j2zAiFI4Th-pKlbhDTvRFQWYTcn5lFFpv1o7eE_NAZ7EdNG7OdNJrrSBH0w3UW2XUtwGn7OTMujhTNAfUalZ1cOXfLaHNlf7AEpeBvHmchAZL81n1p8_yD5wTZe4omt3_ORhAnJRppqAcR9mAig2c-GcyKLi8om_UJmqb1RNnmFY',
                        Colors.green,
                        isDark,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildRelatedNewsItem(
                        'MAINTENANCE',
                        'Server Maintenance: LMS down this Saturday',
                        '2 days ago',
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBeu2sjYd31Wi4PRK5J3X_OJYYoB48tZhfDVFaqvWy8fGyZBM1CUO1icomPS-4KLuD1NLshgfGiwALheCwc3vcpMbyYqfuG4jpr8Hy7QI-w59T2Vsp4h4PnrKnpISdDR2XXb9BJ8ZoNLUPHXD4QXrkQrtiFc1O7ngFcy6Xb6cOHUBBTu5adr-q9qtMk5WCKQhdFb-zliLVvs4um4c8TSj-OUZcBv-rB9ldUetm2cQcDWn5B3DHq3ihivYSh3F4mujzB-KIC83X5Kjo',
                        Colors.orange,
                        isDark,
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Top Header with Buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF101622) : Colors.white).withOpacity(0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                          ),
                          icon: Icon(
                            Icons.share,
                            color: isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                          ),
                          icon: Icon(
                            Icons.bookmark_outline,
                            color: isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Share Button
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, size: 20),
                label: const Text(
                  'Share Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d59f2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 12,
                  shadowColor: const Color(0xFF0d59f2).withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedNewsItem(
    String category,
    String title,
    String time,
    String imageUrl,
    Color categoryColor,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

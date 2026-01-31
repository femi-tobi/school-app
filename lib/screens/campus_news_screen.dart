import 'package:flutter/material.dart';
import '../models/news_article.dart';
import 'news_detail_screen.dart';

class CampusNewsScreen extends StatefulWidget {
  const CampusNewsScreen({super.key});

  @override
  State<CampusNewsScreen> createState() => _CampusNewsScreenState();
}

class _CampusNewsScreenState extends State<CampusNewsScreen> {
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Events',
    'Academic',
    'Maintenance',
    'Sports',
  ];

  final List<NewsArticle> _newsArticles = [
    NewsArticle(
      category: 'LIBRARY UPDATE',
      title: 'Extended Library Hours for Exam Season',
      description: 'Starting next Monday, the main library will remain open 24/7 to support students during the final examination period. Please remember your ID cards for entry.',
      time: '2 hours ago',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvXhOx6tGlUnm8eX10o09_mINyN6rWNdB1y97nmBhQc9LF6Doou_zB5f-fWmT98CXd9je8xrdCgfnnLtUbNsmRNbPus8kkaYK0PV2Cvt1egphc3XfXt-1lckOfTPySz_nrrbKEe-nvVe0WPsyrfG89obUXpef3D1iQl0JADWRHayWWaOhcY4EjUWqS8jmGl8SnYRFPe_h9xx3qvfYQeKrZjYBwBnvfFXQwSbnhhrnIXkswqO5J7PVyYvEj8EJ-SSdDOjTFSyXE0Mo',
      categoryColor: const Color(0xFF0d59f2),
    ),
    NewsArticle(
      category: 'EVENTS',
      title: 'Registration for Inter-College Sports Fest Open',
      description: 'The annual sports extravaganza is back! Sign up for football, basketball, and track events through the student portal before Friday.',
      time: 'Yesterday',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBdL_rDWQ3lAkSqWMm8dwQV-2J_KdGSS2Y6uhzzD1BMcfOtqXkvXAg-aiTY7WEX00yFQZ4JE-NUvEAYn20nObfAMaaZCU_Q-14j2zAiFI4Th-pKlbhDTvRFQWYTcn5lFFpv1o7eE_NAZ7EdNG7OdNJrrSBH0w3UW2XUtwGn7OTMujhTNAfUalZ1cOXfLaHNlf7AEpeBvHmchAZL81n1p8_yD5wTZe4omt3_ORhAnJRppqAcR9mAig2c-GcyKLi8om_UJmqb1RNnmFY',
      categoryColor: Colors.green,
    ),
    NewsArticle(
      category: 'MAINTENANCE',
      title: 'Server Maintenance: LMS down this Saturday',
      description: 'Our IT department will be conducting essential server upgrades this Saturday from 10:00 PM to 4:00 AM. Access to the Learning Management System will be unavailable.',
      time: '2 days ago',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBeu2sjYd31Wi4PRK5J3X_OJYYoB48tZhfDVFaqvWy8fGyZBM1CUO1icomPS-4KLuD1NLshgfGiwALheCwc3vcpMbyYqfuG4jpr8Hy7QI-w59T2Vsp4h4PnrKnpISdDR2XXb9BJ8ZoNLUPHXD4QXrkQrtiFc1O7ngFcy6Xb6cOHUBBTu5adr-q9qtMk5WCKQhdFb-zliLVvs4um4c8TSj-OUZcBv-rB9ldUetm2cQcDWn5B3DHq3ihivYSh3F4mujzB-KIC83X5Kjo',
      categoryColor: Colors.orange,
    ),
    NewsArticle(
      category: 'ACADEMIC',
      title: 'New Internship Opportunities at Tech Hub',
      description: 'Over 20 new internship placements have been listed for Engineering and Computer Science students. Check the careers portal for application deadlines.',
      time: '3 days ago',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBfScWBC6pW7XFg0f2jeDiS-rrlLS9NPok4JhydaOqgzXa1MIHoHaTfzSsCL0_zdrADTaQl1uz8o9qvEAhRB_lnc2VXT1vqoiwSQP0nhsD5yZjrQoTT3l2DIH2TSnso1eLmEbuxAJQqv3RKgz0AVtluh2sYI2KVplprERG1h8NL40uV9_Uy0a2U5oSiiEnFNhjrjt8RU6-o8nqYH-PY40QKii4oh5ju0-Kb-xzf3xzYdTJ-0ft4WxWq0xVEmV1yJPR8JC5_3AC9znU',
      categoryColor: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    
                    // Search and Filters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildSearchBar(isDark),
                          const SizedBox(height: 16),
                          _buildFilterChips(isDark),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // News Articles
                    _buildNewsArticles(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF101622) : const Color(0xFFF5F6F8))
            .withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade700,
          ),
          const SizedBox(width: 16),
          Text(
            'Campus News',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a1f2e) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search announcements...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.grey.shade900,
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _filters[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              backgroundColor: isDark ? const Color(0xFF1a1f2e) : Colors.white,
              selectedColor: const Color(0xFF0d59f2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF0d59f2)
                      : isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNewsArticles(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _newsArticles.map((article) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildNewsCard(article, isDark),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NewsDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1f2e) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage(article.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: article.categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: article.categoryColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Text(
                        article.time,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    article.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

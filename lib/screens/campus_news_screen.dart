import 'package:flutter/material.dart';
import '../models/news_article.dart';
import 'news_detail_screen.dart';
import '../services/api_news_service.dart';

class CampusNewsScreen extends StatefulWidget {
  const CampusNewsScreen({super.key});

  @override
  State<CampusNewsScreen> createState() => _CampusNewsScreenState();
}

class _CampusNewsScreenState extends State<CampusNewsScreen> {
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ApiNewsService _newsService = ApiNewsService();
  
  List<String> _filters = ['All'];
  List<NewsArticle> _allArticles = [];
  List<NewsArticle> _displayedArticles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterArticles);
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      final results = await Future.wait([
        _newsService.getCategories(),
        _newsService.getNews(),
      ]);
      
      if (!mounted) return;

      final categories = results[0] as List<String>;
      final articles = results[1] as List<NewsArticle>;

      setState(() {
        _filters = ['All', ...categories];
        _allArticles = articles;
        _displayedArticles = articles;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load news. Please try again.';
      });
    }
  }

  void _filterArticles() {
    final query = _searchController.text.toLowerCase();
    final selectedCategory = _filters[_selectedFilterIndex];

    setState(() {
      _displayedArticles = _allArticles.where((article) {
        final matchesSearch = article.title.toLowerCase().contains(query) ||
            article.description.toLowerCase().contains(query);
        
        final matchesCategory = selectedCategory == 'All' || 
            article.category.toLowerCase() == selectedCategory.toLowerCase();
            
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

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
                _filterArticles();
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
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_displayedArticles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Center(
          child: Text(
            'No news found',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _displayedArticles.map((article) {
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

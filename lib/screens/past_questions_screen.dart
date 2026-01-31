import 'package:flutter/material.dart';
import '../models/past_question_document.dart';
import '../services/past_questions_service.dart';
import 'upload_past_question_screen.dart';

class PastQuestionsScreen extends StatefulWidget {
  const PastQuestionsScreen({super.key});

  @override
  State<PastQuestionsScreen> createState() => _PastQuestionsScreenState();
}

class _PastQuestionsScreenState extends State<PastQuestionsScreen> {
  int _selectedBottomNavIndex = 2; // PQ Library tab
  int _selectedFilterIndex = 0; // All filter
  
  final PastQuestionsService _pastQuestionsService = PastQuestionsService();
  List<PastQuestionDocument> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPastQuestions();
  }

  Future<void> _fetchPastQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _pastQuestionsService.fetchPastQuestions();

    if (result['success'] == true) {
      final List<dynamic> data = result['data'] ?? [];
      setState(() {
        _documents = data.map((item) => PastQuestionDocument(
          id: item['_id'] ?? '',
          courseCode: item['courseCode'] ?? 'Unknown',
          courseName: item['courseName'] ?? item['title'] ?? 'Unknown',
          category: item['category'] ?? item['department'] ?? 'General',
          session: item['session'] ?? '${item['semester'] ?? ''} Semester',
          uploadedBy: item['uploadedBy']?['name'] ?? 'Anonymous',
          isFree: !(item['isPaid'] ?? false),
          iconName: 'description',
          gradientColors: [
            const Color(0xFFDCEEFF),
            const Color(0xFFEFF6FF),
          ],
        )).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Failed to load questions';
        _isLoading = false;
        // Use sample data as fallback
        _documents = _getSampleDocuments();
      });
    }
  }

  List<PastQuestionDocument> _getSampleDocuments() {
    return [
      PastQuestionDocument(
        courseCode: 'CSC 301',
        courseName: 'Data Structures',
        category: 'Computer Science',
        session: '2022/2023 Session',
        uploadedBy: 'Prof. Smith',
        isFree: true,
        iconName: 'menu_book',
        gradientColors: [
          const Color(0xFFDCEEFF),
          const Color(0xFFEFF6FF),
        ],
      ),
      PastQuestionDocument(
        courseCode: 'MAT 202',
        courseName: 'Linear Algebra II',
        category: 'Mathematics',
        session: '2021/2022 Session',
        uploadedBy: 'Dr. Sarah J.',
        isFree: false,
        iconName: 'calculate',
        gradientColors: [
          const Color(0xFFE0E7FF),
          const Color(0xFFEEF2FF),
        ],
      ),
      PastQuestionDocument(
        courseCode: 'BIO 101',
        courseName: 'Cell Biology',
        category: 'Biology',
        session: '2023/2024 Session',
        uploadedBy: 'Student Union',
        isFree: true,
        iconName: 'biotech',
        gradientColors: [
          const Color(0xFFF3E8FF),
          const Color(0xFFFAF5FF),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
            _buildTopBar(isDark),

            // Search Bar
            _buildSearchBar(isDark),

            // Filter Chips
            _buildFilterChips(isDark),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _documents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage ?? 'No past questions found',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchPastQuestions,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchPastQuestions,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: _documents.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildPQCard(_documents[index], isDark),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const UploadPastQuestionScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF0d59f2),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF101622) : const Color(0xFFF5F6F8))
            .withOpacity(0.8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Past Questions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0d121c),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1e293b) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.search,
                color: Color(0xFF0d59f2),
                size: 24,
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search course title or code...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0d121c),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = ['All', 'Level', 'Semester', 'Course'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            final isSelected = _selectedFilterIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0d59f2)
                      : isDark
                          ? const Color(0xFF1e293b)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE5E7EB),
                        ),
                ),
                child: Row(
                  children: [
                    Text(
                      filters[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? Colors.grey[300]
                                : const Color(0xFF0d121c),
                      ),
                    ),
                    if (index > 0) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.expand_more,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? Colors.grey[300]
                                : const Color(0xFF0d121c),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPQCard(PastQuestionDocument doc, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Header with Icon
          Stack(
            children: [
              Container(
                height: 128,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            doc.gradientColors[0].withOpacity(0.3),
                            const Color(0xFF1e293b),
                          ]
                        : doc.gradientColors,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getIconData(doc.iconName),
                    size: 48,
                    color: const Color(0xFF0d59f2).withOpacity(0.4),
                  ),
                ),
              ),
              // Free/Paid Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: doc.isFree
                        ? (isDark
                            ? Colors.green.shade900.withOpacity(0.4)
                            : Colors.green.shade100)
                        : (isDark
                            ? Colors.amber.shade900.withOpacity(0.4)
                            : Colors.amber.shade100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    doc.isFree ? 'FREE' : 'PAID',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: doc.isFree
                          ? (isDark ? Colors.green.shade400 : Colors.green.shade700)
                          : (isDark ? Colors.amber.shade400 : Colors.amber.shade700),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text(
                  doc.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d59f2),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Course Title
                Text(
                  '${doc.courseCode}: ${doc.courseName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0d121c),
                  ),
                ),
                const SizedBox(height: 12),

                // Session
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      doc.session,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Uploader
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Uploaded by ${doc.uploadedBy}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0d59f2),
                          side: const BorderSide(color: Color(0xFF0d59f2)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          doc.isFree ? Icons.download : Icons.payments,
                          size: 18,
                        ),
                        label: Text(
                          doc.isFree ? 'Download' : 'Purchase',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d59f2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'calculate':
        return Icons.calculate_outlined;
      case 'biotech':
        return Icons.biotech_outlined;
      default: // menu_book
        return Icons.menu_book;
    }
  }

  Widget _buildBottomNav(bool isDark) {
    final items = [
      {'icon': Icons.schedule, 'label': 'Timetable', 'index': 0},
      {'icon': Icons.assignment_outlined, 'label': 'Plans', 'index': 1},
      {'icon': Icons.library_books, 'label': 'PQ Library', 'index': 2},
      {'icon': Icons.account_circle_outlined, 'label': 'Profile', 'index': 3},
    ];

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1a1f2e) : Colors.white).withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((item) {
              final isSelected = _selectedBottomNavIndex == item['index'];
              return GestureDetector(
                onTap: () {
                  if (item['index'] == 0) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      _selectedBottomNavIndex = item['index'] as int;
                    });
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isSelected
                          ? const Color(0xFF0d59f2)
                          : isDark
                              ? Colors.grey[500]
                              : Colors.grey[400],
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF0d59f2)
                            : isDark
                                ? Colors.grey[500]
                                : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

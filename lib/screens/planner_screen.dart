import 'package:flutter/material.dart';
import '../models/study_session.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  int _selectedDayIndex = 0; // Monday selected
  int _selectedBottomNavIndex = 1; // Planner tab

  final List<Map<String, dynamic>> _weekDays = [
    {'day': 'Mon', 'date': '12', 'hasTasks': true},
    {'day': 'Tue', 'date': '13', 'hasTasks': false},
    {'day': 'Wed', 'date': '14', 'hasTasks': false},
    {'day': 'Thu', 'date': '15', 'hasTasks': false},
    {'day': 'Fri', 'date': '16', 'hasTasks': false},
    {'day': 'Sat', 'date': '17', 'hasTasks': false},
  ];

  final List<StudySession> _todaySessions = [
    StudySession(
      courseCode: 'CS101',
      courseName: 'Data Structures',
      topic: 'Binary Search Trees',
      startTime: '14:00',
      endTime: '15:30',
      durationMinutes: 90,
      status: 'in_progress',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAiy4Sc3VnVjYJiLpC6emcsXHUrZJbqt7qURr22NSPLLiTjN6ux1VIhQrA0kI_f35gNrwuLHFTKD2GsJjcZp3wUZQ-nnO3_1qp2fXc6utABMiGk-9fahDlvfzjEhesNsdiY-cUPrP10OwmiTs_4l6mcQABpBY0tHS20GmqY8v3umSPhFTVIhfZxBTPaQg7X4lYQsCFh00H8TMVYEU-clQdJYKwmWDkm1EUfejXqZrxV1klkwN6Rowdc9RzGWSbQDJVFbyn8z3FU_20',
    ),
    StudySession(
      courseCode: 'ECON',
      courseName: 'Macro Trends',
      topic: 'Inflation & GDP',
      startTime: '16:00',
      endTime: '17:00',
      durationMinutes: 60,
      status: 'upcoming',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDVJxRjfpkKFrx_qaJInXvbCTjO57HtH54Zvnsxt4DUSDHI14YHeEwATT4L0NBit8ez6QJ-VSgcf2h1uMIa46VkBRw6MpuzxOhH7UEhCZHSrHq4GzIwb_e3EzZ13srhjkjpVUwzQ5CWw9by4NyzBM8pMFYiMARWNhpzfQ4Zg9Nmvaby1CTzFKy5y0DGzRBZqE2jcKOXhFE9jHlJNCCYYULWuJ59sSX8FVx0agiAh18OJqmB7nYxIRREOUgjYgbdNn3xKS809staMq0',
    ),
  ];

  final List<PastQuestion> _pastQuestions = [
    PastQuestion(
      title: '2023 Finals: Calculus II',
      subtitle: 'Not started • 12 Questions',
      icon: 'quiz',
      iconColor: 'orange',
    ),
    PastQuestion(
      title: 'Bio Lab Report: Genetics',
      subtitle: 'Completed yesterday',
      icon: 'description',
      iconColor: 'green',
      completed: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(isDark),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weekly Calendar Chips
                    _buildWeeklyCalendar(isDark),

                    // Today's Sessions Section
                    _buildSectionHeader(
                      'Today\'s Sessions',
                      'You have ${_todaySessions.length} blocks planned for today',
                      isDark,
                    ),

                    // Sessions List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _todaySessions.map((session) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildSessionCard(session, isDark),
                          );
                        }).toList(),
                      ),
                    ),

                    // Past Questions Section
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildSectionHeader(
                        'Past Questions Focus',
                        'Review these for upcoming midterm',
                        isDark,
                      ),
                    ),

                    // Past Questions List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _pastQuestions.map((question) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildPastQuestionCard(question, isDark),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 100), // Space for FAB and bottom nav
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNav(isDark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new study session
        },
        backgroundColor: const Color(0xFF0d59f2),
        elevation: 8,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
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
              'Study Planner',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0d121c),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_weekDays.length, (index) {
            final day = _weekDays[index];
            final isSelected = _selectedDayIndex == index;
            final hasTasks = day['hasTasks'] as bool;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
              child: Container(
                width: 56,
                height: 80,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0d59f2)
                      : isDark
                          ? const Color(0xFF1e293b)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0d59f2).withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day['day']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : isDark
                                ? Colors.grey[400]
                                : const Color(0xFF49659c),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day['date']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? Colors.white
                                : const Color(0xFF0d121c),
                      ),
                    ),
                    if (isSelected && hasTasks) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
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

  Widget _buildSectionHeader(String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0d121c),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : const Color(0xFF49659c),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(StudySession session, bool isDark) {
    final isActive = session.status == 'in_progress';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? null
            : Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            if (isActive)
              Container(
                width: 4,
                height: 160,
                color: const Color(0xFF0d59f2),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Content
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isActive) ...[
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0d59f2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'IN PROGRESS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0d59f2),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            '${session.courseCode}: ${session.courseName}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0d121c),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Topic: ${session.topic}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : const Color(0xFF49659c),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${session.startTime} - ${session.endTime} (${session.durationMinutes}m)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Buttons
                          Row(
                            children: [
                              if (isActive) ...[
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0d59f2),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Resume',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? Colors.white : const Color(0xFF0d121c),
                                  backgroundColor: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF1F5F9),
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Thumbnail
                    if (session.imageUrl != null)
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(session.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastQuestionCard(PastQuestion question, bool isDark) {
    Color iconBgColor;
    Color iconColor;

    if (question.iconColor == 'orange') {
      iconBgColor = isDark ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade100;
      iconColor = Colors.orange.shade600;
    } else {
      iconBgColor = isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade100;
      iconColor = Colors.green.shade600;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              question.icon == 'quiz' ? Icons.quiz : Icons.description,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0d121c),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : const Color(0xFF49659c),
                  ),
                ),
              ],
            ),
          ),
          // Trailing Icon
          Icon(
            question.completed ? Icons.check_circle : Icons.chevron_right,
            color: question.completed ? Colors.green.shade500 : Colors.grey.shade400,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final items = [
      {'icon': Icons.dashboard, 'label': 'Home', 'index': 0},
      {'icon': Icons.edit_calendar, 'label': 'Planner', 'index': 1},
      {'icon': Icons.school_outlined, 'label': 'Courses', 'index': 2},
      {'icon': Icons.person_outline, 'label': 'Profile', 'index': 3},
    ];

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF101622) : Colors.white).withOpacity(0.9),
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
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

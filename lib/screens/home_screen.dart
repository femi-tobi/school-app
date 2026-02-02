import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_auth_service.dart';
import '../services/api_timetable_service.dart';
import '../services/api_notification_service.dart';
import '../models/timetable_class.dart';
import '../main.dart';
import 'timetable_screen.dart';
import 'planner_screen.dart';
import 'past_questions_screen.dart';
import 'upload_past_question_screen.dart';
import 'profile_screen.dart';
import 'campus_news_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Timer? _timer;
  
  // User data
  final ApiAuthService _authService = ApiAuthService();
  String _userName = 'User';
  String? _userAvatar;
  
  // Next Class Data
  final ApiTimetableService _timetableService = ApiTimetableService();
  TimetableClass? _nextClass;
  DateTime? _nextClassDateTime; // The exact Date and Time of the next class
  Duration _timeUntilClass = Duration.zero;
  bool _isLoadingNextClass = true;

  // Notifications
  final ApiNotificationService _notificationService = ApiNotificationService();
  int _unreadNotificationsCount = 0;

  
  // Streak data
  int _streakDays = 1;
  int _nextMilestone = 7;
  bool _isLoadingStreak = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _calculateStreak();
    _loadNextClass();
    _loadUnreadCount();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user['fullName'] ?? user['name'] ?? 'User';
        _userAvatar = user['avatar'];
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) setState(() => _unreadNotificationsCount = count);
  }

  // Get greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Future<void> _loadNextClass() async {
    try {
      final timetable = await _timetableService.getTimetable();
      final now = DateTime.now();
      final todayIndex = now.weekday - 1; // 0=Mon, 6=Sun
      
      TimetableClass? foundClass;
      DateTime? foundClassDateTime;
      
      // 1. Check classes for today (starting from now)
      if (timetable.containsKey(todayIndex)) {
        final todayClasses = timetable[todayIndex]!;
        
        for (final cls in todayClasses) {
           final clsTime = _parseDateTime(now, cls.startTime);
           if (clsTime != null && clsTime.isAfter(now)) {
             // Found a class later today!
             if (foundClass == null) {
               foundClass = cls;
               foundClassDateTime = clsTime;
             } else if (clsTime.isBefore(foundClassDateTime!)) {
               foundClass = cls;
               foundClassDateTime = clsTime;
             }
           }
        }
      }
      
      // 2. If no class found today, check subsequent days (up to 7 days)
      if (foundClass == null) {
        for (int i = 1; i <= 7; i++) {
          final nextDayIndex = (todayIndex + i) % 7;
          if (timetable.containsKey(nextDayIndex)) {
            final classes = timetable[nextDayIndex]!;
            if (classes.isNotEmpty) {
               // Parse times to find the earliest one in the day
               for (final cls in classes) {
                 // Calculate date for this day
                 final clsDate = now.add(Duration(days: i));
                 // Set time
                 final clsTime = _parseDateTime(clsDate, cls.startTime);
                 
                 if (clsTime != null) {
                   if (foundClass == null) {
                      foundClass = cls;
                      foundClassDateTime = clsTime;
                   } else if (clsTime.isBefore(foundClassDateTime!)) {
                      foundClass = cls;
                      foundClassDateTime = clsTime;
                   }
                 }
               }
               // If we found any class on this nearest day, stop searching further days
               if (foundClass != null) break;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _nextClass = foundClass;
          _nextClassDateTime = foundClassDateTime;
          _isLoadingNextClass = false;
        });
      }
      
    } catch (e) {
      print('Error loading next class: $e');
      if (mounted) setState(() => _isLoadingNextClass = false);
    }
  }

  DateTime? _parseDateTime(DateTime date, String timeHtml) {
    try {
      // timeHtml format example: "08:00 AM"
      final parts = timeHtml.trim().split(' ');
      if (parts.length != 2) return null;
      
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextClassDateTime == null) return;
      
      final now = DateTime.now();
      final diff = _nextClassDateTime!.difference(now);
      
      if (mounted) {
        setState(() {
          if (diff.isNegative) {
            _timeUntilClass = Duration.zero;
            // Optionally reload to find the next one
            if (diff.abs().inSeconds > 60) _loadNextClass(); 
          } else {
            _timeUntilClass = diff;
          }
        });
      }
    });
  }

  Future<void> _calculateStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginString = prefs.getString('last_login_date');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      int currentStreak = prefs.getInt('current_streak') ?? 0;

      if (lastLoginString != null) {
        final lastLogin = DateTime.parse(lastLoginString);
        final lastLoginDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
        
        final difference = today.difference(lastLoginDate).inDays;
        
        if (difference == 0) {
          // Already logged in today
        } else if (difference == 1) {
          // Consecutive day
          currentStreak++;
        } else {
          // Streak broken
          currentStreak = 1;
        }
      } else {
        // First time login
        currentStreak = 1;
      }
      
      // Save today as last login
      await prefs.setString('last_login_date', today.toIso8601String());
      await prefs.setInt('current_streak', currentStreak);

      if (mounted) {
        setState(() {
          _streakDays = currentStreak;
          // Logic for next milestone
          if (_streakDays < 3) _nextMilestone = 3;
          else if (_streakDays < 7) _nextMilestone = 7;
          else if (_streakDays < 14) _nextMilestone = 14;
          else if (_streakDays < 30) _nextMilestone = 30;
          else _nextMilestone = _streakDays + 10;
          
          _isLoadingStreak = false;
        });
      }
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      if (mounted) {
        setState(() {
          _isLoadingStreak = false;
        });
      }
    }
  }

  // Build initials avatar placeholder
  Widget _buildInitials() {
    final initials = _userName.isNotEmpty
        ? _userName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  
                  // Next Class Card
                  _buildNextClassCard(isDark),
                  
                  const SizedBox(height: 24),
                  
                  // Study Streak
                  _buildStudyStreak(isDark),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Shortcuts
                  _buildQuickShortcuts(isDark),
                  
                  const SizedBox(height: 24),
                  
                  // Campus News
                  _buildCampusNews(isDark),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNav(isDark),
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
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Profile Picture - Now using real avatar or initials
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: _userAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        _userAvatar!,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) => _buildInitials(),
                      ),
                    )
                  : _buildInitials(),
            ),
          ),
          const SizedBox(width: 12),
          
          // Greeting - Now dynamic
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _userName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0d121c),
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Notification Icon
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? Colors.grey[200] : Colors.grey[700],
                ),
                onPressed: () async {
                  await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const NotificationScreen())
                  );
                  _loadUnreadCount(); // Refresh on return
                },
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF101622) : const Color(0xFFF5F6F8),
                        width: 1.5,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        _unreadNotificationsCount > 9 ? '9+' : '$_unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextClassCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NEXT CLASS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1e293b) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isLoadingNextClass
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _nextClass == null
                  ? Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.event_busy, 
                                size: 48, 
                                color: isDark ? Colors.grey[600] : Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No Upcoming Classes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
            children: [
              // Class Image
              Stack(
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://picsum.photos/seed/tech/400/200', // Generic tech image for now
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0d59f2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'STARTS IN ${_timeUntilClass.inHours}:${(_timeUntilClass.inMinutes % 60).toString().padLeft(2, '0')}:${(_timeUntilClass.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_nextClass!.courseCode} - ${_nextClass!.courseName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Countdown and Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Countdown
                    Row(
                      children: [
                        _buildTimeBox(isDark, '${_timeUntilClass.inHours}', 'HOURS'),
                        const SizedBox(width: 8),
                         _buildTimeBox(isDark, '${_timeUntilClass.inMinutes % 60}', 'MINS'),
                        const SizedBox(width: 8),
                         _buildTimeBox(isDark, '${_timeUntilClass.inSeconds % 60}', 'SECS'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.location_on, size: 18),
                            label: Text('Loc: ${_nextClass!.location}'), // Show Location
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0d59f2),
                              foregroundColor: Colors.white,
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
        ),
      ],
    );
  }

  Widget _buildTimeBox(bool isDark, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                value.padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0d59f2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyStreak(bool isDark) {
    // Calculate progress fraction
    // e.g. streak 5, milestone 7 -> 5/7
    double progress = _streakDays / _nextMilestone;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_streakDays Day Study Streak',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0d121c),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0d59f2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Next: $_nextMilestone Days',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d59f2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0d59f2)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _streakDays == 1 
              ? 'Great start! Consistency is key.' 
              : 'Keep it up! ${_nextMilestone - _streakDays} more days for the next milestone.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickShortcuts(bool isDark) {
    final shortcuts = [
      {'icon': Icons.calendar_month, 'label': 'Timetable'},
      {'icon': Icons.task_alt, 'label': 'Planner'},
      {'icon': Icons.quiz, 'label': 'PQs'},
      {'icon': Icons.upload_file, 'label': 'Upload'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) {
        final shortcut = shortcuts[index];
        return GestureDetector(
          onTap: () {
            if (index == 0) {
              // Navigate to Timetable screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TimetableScreen()),
              );
            } else if (index == 1) {
              // Navigate to Planner screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlannerScreen()),
              );
            } else if (index == 2) {
              // Navigate to Past Questions screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PastQuestionsScreen()),
              );
            } else if (index == 3) {
              // Navigate to Upload Past Question screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UploadPastQuestionScreen()),
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1e293b) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      shortcut['icon'] as IconData,
                      size: 28,
                      color: const Color(0xFF0d59f2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shortcut['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampusNews(bool isDark) {
    final news = [
      {
        'category': 'LIBRARY UPDATE',
        'categoryColor': const Color(0xFF0d59f2),
        'title': 'Extended Library Hours for Exam Season',
        'time': '2 hours ago',
        'image': 'https://picsum.photos/seed/library/400/200',
      },
      {
        'category': 'EVENTS',
        'categoryColor': Colors.green,
        'title': 'Registration for Inter-College Sports Fest Open',
        'time': 'Yesterday',
        'image': 'https://picsum.photos/seed/sports/400/200',
      },
      {
        'category': 'MAINTENANCE',
        'categoryColor': Colors.orange,
        'title': 'Server Maintenance: LMS down this Saturday',
        'time': '2 days ago',
        'image': 'https://picsum.photos/seed/tech/400/200',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Campus News',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0d121c),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CampusNewsScreen()),
                );
              },
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
        ...news.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1e293b) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
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
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['image'] as String),
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
                        item['category'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: item['categoryColor'] as Color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0d121c),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final items = [
      {'icon': Icons.home, 'label': 'Home', 'index': 0},
      {'icon': Icons.menu_book_outlined, 'label': 'Courses', 'index': 1},
      {'icon': Icons.chat_bubble_outline, 'label': 'Social', 'index': 2},
      {'icon': Icons.settings_outlined, 'label': 'Settings', 'index': 3},
    ];

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1e293b) : Colors.white).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((item) {
              final isSelected = _selectedIndex == item['index'];
              return GestureDetector(
                onTap: () {
                  if (item['index'] == 3) {
                    // Navigate to Profile/Settings screen
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  } else {
                    setState(() {
                      _selectedIndex = item['index'] as int;
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
                        fontWeight: FontWeight.bold,
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

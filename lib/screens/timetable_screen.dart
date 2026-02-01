import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timetable_class.dart';
import '../services/api_timetable_service.dart';
import '../services/notification_service.dart';
import 'add_timetable_entry_screen.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDayIndex = 2; // Wednesday is selected by default
  int _selectedBottomNavIndex = 1; // Timetable tab selected
  bool _showMonthCalendar = false; // Toggle between week and month view
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<Map<String, dynamic>> _weekDays = [
    {'day': 'Mon', 'date': '14'},
    {'day': 'Tue', 'date': '15'},
    {'day': 'Wed', 'date': '16'},
    {'day': 'Thu', 'date': '17'},
    {'day': 'Fri', 'date': '18'},
    {'day': 'Sat', 'date': '19'},
  ];

  Map<int, List<TimetableClass>> _timetableData = {};
  bool _isLoading = true;
  final ApiTimetableService _timetableService = ApiTimetableService();

  @override
  void initState() {
    super.initState();
    _loadTimetable();
    NotificationService().init();
  }

  Future<void> _loadTimetable() async {
    try {
      final data = await _timetableService.getTimetable();
      if (mounted) {
        setState(() {
          _timetableData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load timetable: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final classes = _timetableData[_selectedDayIndex] ?? [];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),
            
            // Date Selector
            _buildDateSelector(isDark),
            
            // Class List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF0d59f2),
                        ),
                      ),
                    )
                  : classes.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                          itemCount: classes.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildClassCard(classes[index], index, isDark),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTimetableEntryScreen(),
            ),
          );
          if (result == true) {
            _loadTimetable();
          }
        },
        backgroundColor: const Color(0xFF0d59f2),
        elevation: 8,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF0d59f2).withOpacity(0.2),
                width: 2,
              ),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCZkPMGpIQfaBh63Fe2MFqZrhAB0ALH02MXnR8uj49hn8vd6JmqdlJ8EE8WbzUufiOsu0yGO_sM-yLRbBSG6_-AIvKu5lj4G2CmwADHxisEYTPY_SJH5qrdnpXKrZ8e8dHNjr84w1Ij3y82ijpPwlvQGN_gPiHnEBrKNibUMXdRVXWM7LU03zF34EDT4NPSbxOL5-pYpUkJyvKpwxy2g8L-n2uDzGXmmCz51x6j_emEQtuu2L_i4EQAm32sRTtLp-j3pDKQwmiSB_A',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCHEDULE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
              const Text(
                'Timetable',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Notification Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
              border: Border.all(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 22,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return Column(
      children: [
        // Toggle button and month/year header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1e293b) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showMonthCalendar
                    ? '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}'
                    : 'This Week',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              IconButton(
                icon: Icon(
                  _showMonthCalendar ? Icons.view_week : Icons.calendar_month,
                  color: const Color(0xFF0d59f2),
                ),
                onPressed: () {
                  setState(() {
                    _showMonthCalendar = !_showMonthCalendar;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Calendar view (week or month)
        if (_showMonthCalendar)
          _buildMonthCalendar(isDark)
        else
          _buildWeekSelector(isDark),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  Widget _buildWeekSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_weekDays.length, (index) {
            final day = _weekDays[index];
            final isSelected = _selectedDayIndex == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
              child: Container(
                width: 56,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0d59f2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0d59f2).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      day['day']!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : isDark
                                ? Colors.grey[400]
                                : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: Text(
                        day['date']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMonthCalendar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            // Update selected day index based on the selected date
            if (selectedDay.day == 16) {
              _selectedDayIndex = 2; // Wednesday has classes
            }
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarFormat: CalendarFormat.month,
        headerVisible: false,
        daysOfWeekHeight: 40,
        calendarStyle: CalendarStyle(
          // Today's date
          todayDecoration: BoxDecoration(
            color: const Color(0xFF0d59f2).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
          // Selected date
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF0d59f2),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          // Default days
          defaultTextStyle: TextStyle(
            color: isDark ? Colors.grey[300] : const Color(0xFF0F172A),
          ),
          // Weekend days
          weekendTextStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          // Outside days
          outsideTextStyle: TextStyle(
            color: isDark ? Colors.grey[700] : Colors.grey[400],
          ),
          // Markers for days with classes
          markerDecoration: const BoxDecoration(
            color: Color(0xFF10b981),
            shape: BoxShape.circle,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[500],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        // Add markers for days with classes
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            // Add marker if this date has classes (e.g., 16th)
            if (date.day == 16) {
              return Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10b981),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildClassCard(TimetableClass classInfo, int index, bool isDark) {
    Color accentColor;
    Color timeColor;
    
    switch (classInfo.accentColor) {
      case 'emerald':
        accentColor = const Color(0xFF10b981);
        timeColor = const Color(0xFF059669);
        break;
      case 'amber':
        accentColor = const Color(0xFFf59e0b);
        timeColor = const Color(0xFFd97706);
        break;
      default: // primary
        accentColor = const Color(0xFF0d59f2);
        timeColor = const Color(0xFF0d59f2);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1e293b) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
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
            // Colored left border
            Container(
              width: 4,
              color: accentColor,
            ),
            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${classInfo.startTime} - ${classInfo.endTime}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: timeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${classInfo.courseCode}: ${classInfo.courseName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    classInfo.iconName == 'calculate'
                        ? Icons.calculate_outlined
                        : Icons.science_outlined,
                    color: accentColor,
                    size: 22,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Location and Professor
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      classInfo.location,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      classInfo.professor,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _editClass(classInfo, index);
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.grey[300] : Colors.grey[700],
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      // ...
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _confirmDelete(classInfo, index);
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(
                        color: Colors.red.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
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
  
  void _editClass(TimetableClass classInfo, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTimetableEntryScreen(
          classToEdit: classInfo,
          dayIndex: _selectedDayIndex,
          classIndex: index,
        ),
      ),
    );
    if (result == true) {
      _loadTimetable();
    }
  }

  void _confirmDelete(TimetableClass classInfo, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class?'),
        content: Text('Are you sure you want to delete ${classInfo.courseCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              setState(() => _isLoading = true);
              
              try {
                final success = await _timetableService.deleteTimetableEntry(
                  _selectedDayIndex,
                  index,
                );
                
                if (success) {
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Class deleted successfully')),
                     );
                     _loadTimetable();
                   }
                } else {
                   if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete class')),
                      );
                   }
                }
              } catch (e) {
                 if (mounted) {
                    setState(() => _isLoading = false);
                 }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No classes scheduled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a class',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final items = [
      {'icon': Icons.grid_view, 'index': 0},
      {'icon': Icons.calendar_month, 'index': 1},
      {'icon': Icons.school_outlined, 'index': 2},
      {'icon': Icons.person_outline, 'index': 3},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((item) {
              final isSelected = _selectedBottomNavIndex == item['index'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBottomNavIndex = item['index'] as int;
                  });
                  if (item['index'] == 0) {
                    Navigator.of(context).pop();
                  }
                },
                child: Icon(
                  item['icon'] as IconData,
                  color: isSelected
                      ? const Color(0xFF0d59f2)
                      : isDark
                          ? Colors.grey[500]
                          : Colors.grey[400],
                  size: 26,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _setReminder(TimetableClass classInfo) async {
    // Show time picker to select reminder offset
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 15),
      helpText: 'Remind me before class starts',
    );

    if (time != null) {
      // For demo purposes, we'll just schedule it 10 seconds from now
      // In a real app, calculate based on classInfo.startTime
      final notificationService = NotificationService();
      await notificationService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Class Reminder: ${classInfo.courseCode}',
        body: '${classInfo.courseName} starts soon at ${classInfo.location}',
        scheduledDate: DateTime.now().add(const Duration(seconds: 10)),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set for ${classInfo.courseCode}'),
            backgroundColor: const Color(0xFF0d59f2),
          ),
        );
      }
    }
  }

  Future<void> _addNote(TimetableClass classInfo) async {
    // Check if there is an existing note
    final prefs = await SharedPreferences.getInstance();
    final noteKey = 'note_${classInfo.courseCode}';
    String? currentNote = prefs.getString(noteKey);
    
    final noteController = TextEditingController(text: currentNote);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Note for ${classInfo.courseCode}'),
          content: TextField(
            controller: noteController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter assignment details, reminders, or general notes...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = noteController.text.trim();
                if (text.isEmpty) {
                  await prefs.remove(noteKey);
                } else {
                  await prefs.setString(noteKey, text);
                }
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note saved successfully')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0d59f2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

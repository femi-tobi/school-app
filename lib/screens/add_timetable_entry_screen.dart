import 'package:flutter/material.dart';
import '../models/timetable_class.dart';
import '../services/api_timetable_service.dart';

class AddTimetableEntryScreen extends StatefulWidget {
  final TimetableClass? classToEdit;
  final int? dayIndex;
  final int? classIndex;

  const AddTimetableEntryScreen({
    super.key,
    this.classToEdit,
    this.dayIndex,
    this.classIndex,
  });

  @override
  State<AddTimetableEntryScreen> createState() => _AddTimetableEntryScreenState();
}

class _AddTimetableEntryScreenState extends State<AddTimetableEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _professorController = TextEditingController();

  String _selectedDay = 'Monday'; // Default day
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isLoading = false;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.classToEdit != null) {
      final cls = widget.classToEdit!;
      _courseCodeController.text = cls.courseCode;
      _courseNameController.text = cls.courseName;
      _locationController.text = cls.location;
      _professorController.text = cls.professor;
      
      // Parse day index back to string
      if (cls.dayIndex >= 0 && cls.dayIndex < _days.length) {
        _selectedDay = _days[cls.dayIndex];
      }
      
      // Parse time strings back to TimeOfDay
      _startTime = _parseTime(cls.startTime);
      _endTime = _parseTime(cls.endTime);
    }
  }

  TimeOfDay _parseTime(String timeString) {
    try {
      // Expected format: "08:00 AM" or similar
      final parts = timeString.split(' '); // ["08:00", "AM"]
      final timeParts = parts[0].split(':'); // ["08", "00"]
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      
      if (parts.length > 1 && parts[1] == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts.length > 1 && parts[1] == 'AM' && hour == 12) {
        hour = 0;
      }
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _locationController.dispose();
    _professorController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final dayIndex = _days.indexOf(_selectedDay);

      final newClass = TimetableClass(
        dayIndex: dayIndex, // Add dayIndex
        courseCode: _courseCodeController.text,
        courseName: _courseNameController.text,
        startTime: _formatTimeOfDay(_startTime),
        endTime: _formatTimeOfDay(_endTime),
        location: _locationController.text,
        professor: _professorController.text,
        iconName: 'science', // Default icon
        accentColor: 'primary', // Default color
      );

      final apiService = ApiTimetableService();
      bool success;
      
      if (widget.classToEdit != null && widget.classIndex != null) {
        // Update existing
        success = await apiService.updateTimetableEntry(
          widget.dayIndex ?? dayIndex, // Use original day index for path if needed, or new one? API likely wants path to find it. 
          // Wait, if I change the day, the path dayIndex refers to OLD location. 
          // But the BODY dayIndex is the NEW location.
          // The API route is PUT /class/:dayIndex/:classIndex. 
          // Assuming params are for FINDING the record.
          widget.classIndex!, 
          newClass
        );
      } else {
        // Add new
        success = await apiService.addTimetableEntry(newClass);
      }

      print('${widget.classToEdit != null ? "Update" : "Add"} timetable entry success: $success');

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Class ${widget.classToEdit != null ? "updated" : "added"} successfully')),
          );
          Navigator.of(context).pop(true); // Return true to trigger refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to ${widget.classToEdit != null ? "update" : "add"} class')),
          );
        }
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classToEdit != null ? 'Edit Class' : 'Add New Class'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _courseCodeController,
                label: 'Course Code',
                hint: 'e.g. PHY 101',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter course code' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _courseNameController,
                label: 'Course Name',
                hint: 'e.g. General Physics',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter course name' : null,
              ),
              const SizedBox(height: 16),
              
              // Day Dropdown
              const Text(
                'Day',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDay,
                    isExpanded: true,
                    items: _days.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDay = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Time',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 20),
                                const SizedBox(width: 8),
                                Text(_formatTimeOfDay(_startTime)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End Time',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context, false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 20),
                                const SizedBox(width: 8),
                                Text(_formatTimeOfDay(_endTime)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'e.g. Hall A',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _professorController,
                label: 'Professor',
                hint: 'e.g. Prof. Smith',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter professor' : null,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d59f2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Class',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

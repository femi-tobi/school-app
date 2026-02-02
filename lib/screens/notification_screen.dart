import 'package:flutter/material.dart';
import '../services/api_notification_service.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiNotificationService _notificationService = ApiNotificationService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final data = await _notificationService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    final success = await _notificationService.markAllRead();
    if (success) {
      // Optimistically update
      setState(() {
        for (var n in _notifications) {
          if (n is Map) n['read'] = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _notificationService.clearAll();
      if (success) {
        setState(() => _notifications = []);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications cleared')),
          );
        }
      }
    }
  }

  Future<void> _markOneRead(String id, int index) async {
    // If already read, skip
    final n = _notifications[index];
    if (n is Map && n['read'] == true) return;

    // Optimistic update
    setState(() {
      if (_notifications[index] is Map) _notifications[index]['read'] = true;
    });

    await _notificationService.markAsRead(id);
  }

  Future<void> _deleteNotification(String id, int index) async {
    // Optimistic remove
    final removed = _notifications[index];
    setState(() {
      _notifications.removeAt(index);
    });

    final success = await _notificationService.deleteNotification(id);
    if (!success) {
      // Revert if failed
      if (mounted) {
        setState(() {
          _notifications.insert(index, removed);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete notification')),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return DateFormat.jm().format(date);
      } else {
        return DateFormat.MMMd().add_jm().format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _notifications.isEmpty ? null : _markAllRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear all',
            onPressed: _notifications.isEmpty ? null : _clearAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 64, color: isDark ? Colors.grey[700] : Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    if (n is! Map) return const SizedBox.shrink();

                    final id = n['_id'] ?? n['id'] ?? '';
                    final title = n['title'] ?? 'No Title';
                    final body = n['body'] ?? n['message'] ?? '';
                    final isRead = n['read'] == true;
                    final dateStr = n['createdAt'] ?? n['timestamp'];

                    return Dismissible(
                      key: Key(id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteNotification(id.toString(), index),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isRead ? 0 : 2,
                        color: isDark
                            ? (isRead ? Colors.transparent : const Color(0xFF1E293B))
                            : (isRead ? Colors.transparent : Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            width: isRead ? 0 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isRead 
                                  ? (isDark ? Colors.grey[800] : Colors.grey[200])
                                  : Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isRead ? Icons.notifications_none : Icons.notifications_active,
                              color: isRead 
                                  ? Colors.grey 
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                body,
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              if (dateStr != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(dateStr),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () => _markOneRead(id.toString(), index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

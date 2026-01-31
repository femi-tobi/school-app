import 'package:flutter/material.dart';
import '../../models/onboarding_item.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({
    super.key,
    required this.item,
  });

  Color _parseColor(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image container with floating elements
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            _parseColor('#0d59f2').withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Floating elements
                  ...item.floatingElements.map((element) {
                    return Positioned(
                      top: element.top,
                      bottom: element.bottom,
                      left: element.left,
                      right: element.right,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF101622).withOpacity(0.9)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconData(element.icon),
                              color: _parseColor(element.accentColor),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 8,
                              width: element.icon == 'calendar_today' ? 64 : 80,
                              decoration: BoxDecoration(
                                color: _parseColor(element.accentColor).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Title
          Text(
            item.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: isDark ? Colors.white : const Color(0xFF0d121c),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              item.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isDark
                    ? const Color(0xFF94a3b8)
                    : const Color(0xFF64748b),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'calendar_today':
        return Icons.calendar_today;
      case 'check_circle':
        return Icons.check_circle;
      case 'description':
        return Icons.description;
      case 'history_edu':
        return Icons.history_edu;
      case 'verified':
        return Icons.verified;
      case 'timer':
        return Icons.timer;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'trending_up':
        return Icons.trending_up;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'groups':
        return Icons.groups;
      case 'share':
        return Icons.share;
      default:
        return Icons.circle;
    }
  }
}

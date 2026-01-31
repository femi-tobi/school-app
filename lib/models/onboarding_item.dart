class OnboardingItem {
  final String title;
  final String description;
  final String imageUrl;
  final List<FloatingElement> floatingElements;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.floatingElements,
  });
}

class FloatingElement {
  final String icon;
  final double top;
  final double? bottom;
  final double? left;
  final double? right;
  final String accentColor;

  const FloatingElement({
    required this.icon,
    this.top = 0,
    this.bottom,
    this.left,
    this.right,
    required this.accentColor,
  });
}

// Onboarding data
final List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    title: 'Study smarter,\npass better',
    description: 'Timetables, past questions & study plans — built specifically for students to excel.',
    imageUrl: 'https://picsum.photos/seed/onboarding1/600/600',
    floatingElements: [
      FloatingElement(
        icon: 'calendar_today',
        top: 16,
        right: 16,
        accentColor: '#0d59f2',
      ),
      FloatingElement(
        icon: 'check_circle',
        bottom: 40,
        left: 16,
        accentColor: '#10b981',
      ),
    ],
  ),
  OnboardingItem(
    title: 'Ace your exams',
    description: 'Access thousands of verified past questions and solutions anytime, anywhere.',
    imageUrl: 'https://picsum.photos/seed/onboarding2/600/600',
    floatingElements: [
      FloatingElement(
        icon: 'description',
        top: 32,
        left: 24,
        accentColor: '#0d59f2',
      ),
      FloatingElement(
        icon: 'history_edu',
        top: 180,
        right: 16,
        accentColor: '#f59e0b',
      ),
      FloatingElement(
        icon: 'verified',
        bottom: 48,
        left: 100,
        accentColor: '#10b981',
      ),
    ],
  ),
  OnboardingItem(
    title: 'Track your progress',
    description: 'Build study streaks, set goals, and manage your time effectively with our smart planner.',
    imageUrl: 'https://picsum.photos/seed/onboarding3/600/600',
    floatingElements: [
      FloatingElement(
        icon: 'timer',
        top: 32,
        right: 24,
        accentColor: '#0d59f2',
      ),
      FloatingElement(
        icon: 'local_fire_department',
        bottom: 48,
        left: 24,
        accentColor: '#f59e0b',
      ),
    ],
  ),
];

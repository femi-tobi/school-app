import 'package:flutter/material.dart';
import '../services/api_auth_service.dart';
import 'onboarding/onboarding_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiAuthService _authService = ApiAuthService();
  
  // User data from API
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('DEBUG: Loading user data for ProfileScreen');
    
    // First try to get cached user data
    final cachedUser = await _authService.getCurrentUser();
    print('DEBUG: Cached user data: $cachedUser');
    
    if (cachedUser != null) {
      if (mounted) {
        setState(() {
          _userData = cachedUser;
          _isLoading = false;
        });
      }
    }

    // Then fetch fresh data from API
    try {
      final result = await _authService.fetchCurrentUser();
      print('DEBUG: API fetch result: $result');
      
      if (result['success'] == true && result['user'] != null && mounted) {
        setState(() {
          _userData = result['user'];
          _isLoading = false;
        });
      } else if (mounted) {
        // If API fails but we have cached data, keep it. 
        // If we have no data, stop loading.
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('DEBUG: Error fetching user data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to get user field with fallback
  String _getUserField(String field, String fallback) {
    if (_userData == null) return fallback;
    final value = _userData![field];
    if (value == null || value.toString().isEmpty) return fallback;
    return value.toString();
  }

  // Build avatar placeholder with initials
  Widget _buildAvatarPlaceholder(Color primaryColor) {
    final name = _getUserField('name', 'User');
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';
    
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopBar(isDark),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Section
                    _buildProfileHeader(isDark, primaryColor),
                    
                    const SizedBox(height: 24),
                    
                    // Financial & Subscription Section
                    _buildFinancialSection(isDark, primaryColor),
                    
                    const SizedBox(height: 32),
                    
                    // App Preferences Section
                    _buildPreferencesSection(isDark),
                    
                    const SizedBox(height: 32),
                    
                    // Logout Button
                    _buildLogoutSection(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            // Profile Picture with Edit Badge
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor,
                      width: 2,
                    ),
                    color: primaryColor.withOpacity(0.1),
                  ),
                  child: _userData?['avatar'] != null
                      ? ClipOval(
                          child: Image.network(
                            _userData!['avatar'],
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildAvatarPlaceholder(primaryColor),
                          ),
                        )
                      : _buildAvatarPlaceholder(primaryColor),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1a1f2e) : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 20),
            
            // User Info - Now using real data
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getUserField('name', 'User'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getUserField('university', 'No university set'),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getUserField('department', 'No department')} | ${_getUserField('level', '')} Level',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'FINANCIAL & SUBSCRIPTION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
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
              children: [
                // Subscription Item
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.credit_card,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subscription & Billing',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Premium Plan expires in 20 days',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Wallet Item
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wallet Balance',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₦5,200.00 earned from PQ uploads',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Withdraw',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(bool isDark) {
    final preferences = [
      {
        'icon': Icons.person_outline,
        'color': Colors.blue,
        'title': 'Edit Profile',
        'subtitle': 'Update your personal information',
        'route': 'edit_profile',
      },
      {
        'icon': Icons.lock_outline,
        'color': Colors.orange,
        'title': 'Change Password',
        'subtitle': 'Update your account password',
        'route': 'change_password',
      },
      {
        'icon': Icons.notifications,
        'color': Colors.red,
        'title': 'Notification Preferences',
        'subtitle': 'Manage alerts and activity updates',
        'route': null,
      },
      {
        'icon': Icons.shield,
        'color': Colors.indigo,
        'title': 'Data & Privacy',
        'subtitle': 'Control your data visibility',
        'route': null,
      },
      {
        'icon': Icons.help_center,
        'color': Colors.grey,
        'title': 'Support & FAQ',
        'subtitle': 'Need help? We are here for you',
        'route': null,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'APP PREFERENCES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
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
              children: preferences.asMap().entries.map((entry) {
                final index = entry.key;
                final pref = entry.value;
                final isLast = index == preferences.length - 1;
                
                return InkWell(
                  onTap: () {
                    final route = pref['route'];
                    if (route == 'edit_profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      ).then((updated) {
                        if (updated == true) _loadUserData(); // Refresh data if updated
                      });
                    } else if (route == 'change_password') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: isDark 
                                    ? Colors.grey.shade800.withOpacity(0.5) 
                                    : Colors.grey.shade100,
                              ),
                            ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (pref['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            pref['icon'] as IconData,
                            color: pref['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pref['title'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pref['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Show logout confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Save references BEFORE any async operations
                          final navigator = Navigator.of(context);
                          
                          // Close the dialog first
                          navigator.pop();
                          
                          // Call logout API and clear session
                          await _authService.logout();
                          
                          // Navigate to onboarding/login screen and remove all previous routes
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark 
                    ? Colors.red.shade900.withOpacity(0.2) 
                    : Colors.red.shade50,
                foregroundColor: isDark ? Colors.red.shade400 : Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark 
                        ? Colors.red.shade900.withOpacity(0.5) 
                        : Colors.red.shade200,
                  ),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text(
                    'Logout from Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'VERSION 2.4.1 (BUILD 4022)',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

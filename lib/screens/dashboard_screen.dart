import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './chat_consultant_screen.dart';
import './calorie_tracking_screen.dart';
import './reminder_screen.dart';
import './health_monitoring_screen.dart';
import './recipe_recognition_screen.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  static const Color customOrange = Color(0xFFE07E02);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.currentUser != null) {
        await authService.logout(userProvider.currentUser!.id);
      }

      await userProvider.clearUser();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/welcome');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToFeature(String feature) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in. Please log in again.'),
        ),
      );
      return;
    }

    switch (feature) {
      case 'Chat Consultation':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatConsultantScreen()),
        );
        break;
      case 'Recipe Recognition':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecipeRecognitionScreen(),
          ),
        );
        break;
      case 'Calorie Tracking':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CalorieTrackingScreen(),
          ),
        );
        break;
      case 'Health Monitoring':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HealthMonitoringScreen(),
          ),
        );
        break;
      case 'Reminders':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReminderScreen(),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$feature feature coming soon')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.apple, color: customOrange),
            const SizedBox(width: 8),
            const Text(
              'NutriAI',
              style: TextStyle(
                color: customOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: customOrange,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black87),
              onPressed: _logout,
            ),
        ],
      ),
      body:
          user == null
              ? const Center(child: Text('No user data available'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Welcome, ${user.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (user.isDoctor)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: customOrange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Healthcare Professional',
                            style: TextStyle(
                              color: customOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.chat_bubble_outline,
                            title: 'Chat\nConsultation',
                            backgroundColor: const Color(0xFFF5E6D0),
                            iconColor: Colors.black,
                            onTap:
                                () => _navigateToFeature('Chat Consultation'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.camera_alt_outlined,
                            title: 'Recipe\nRecognition',
                            backgroundColor: Colors.grey.shade300,
                            iconColor: Colors.black,
                            onTap:
                                () => _navigateToFeature('Recipe Recognition'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.analytics_outlined,
                            title: 'Calorie Tracking',
                            backgroundColor: customOrange,
                            iconColor: Colors.white,
                            onTap: () => _navigateToFeature('Calorie Tracking'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.favorite_border,
                            title: 'Health\nMonitoring',
                            backgroundColor: const Color(0xFFF5E6D0),
                            iconColor: Colors.black,
                            onTap:
                                () => _navigateToFeature('Health Monitoring'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.notifications_outlined,
                            title: 'Reminders',
                            backgroundColor: Colors.grey.shade300,
                            iconColor: Colors.black,
                            onTap: () => _navigateToFeature('Reminders'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureCard(
                            icon: Icons.restaurant_outlined,
                            title: 'Meal Plans',
                            backgroundColor: customOrange,
                            iconColor: Colors.white,
                            onTap: () => _navigateToFeature('Meal Plans'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: customOrange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: iconColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

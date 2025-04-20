import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';  // Add this import
import '../services/auth_service.dart';
import '../providers/chat_provider.dart';  // Add this import
import './chat_consultant_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  static const Color customOrange = Color(0xFFE07E02);
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _logout() async {
    try {
      final authService = AuthService();
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getString('userId');
      if (userId != null) {
        await authService.logout(userId);
      }

      await prefs.clear();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/welcome');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: ${e.toString()}')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToFeature(String feature) {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in. Please log in again.')),
      );
      return;
    }

    switch (feature) {
      case 'Chat Consultation':
        // Wrap the ChatConsultantScreen with ChangeNotifierProvider
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => ChatProvider(),
              child: ChatConsultantScreen(
                userId: _userId!,
              ),
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$feature feature coming soon')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the code remains the same
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.apple, color: customOrange),
            const SizedBox(width: 8),
            const Text(
              'NutriAI',
              style: TextStyle(color: customOrange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chat\nConsultation',
                    backgroundColor: const Color(0xFFF5E6D0),
                    iconColor: Colors.black,
                    onTap: () => _navigateToFeature('Chat Consultation'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.camera_alt_outlined,
                    title: 'Recipe\nRecognition',
                    backgroundColor: Colors.grey.shade300,
                    iconColor: Colors.black,
                    onTap: () => _navigateToFeature('Recipe Recognition'),
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
                    icon: Icons.sync_alt,
                    title: 'Food\nSubstitutions',
                    backgroundColor: const Color(0xFFF5E6D0),
                    iconColor: Colors.black,
                    onTap: () => _navigateToFeature('Food Substitutions'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.favorite_border,
                    title: 'Health\nMonitoring',
                    backgroundColor: Colors.grey.shade300,
                    iconColor: Colors.black,
                    onTap: () => _navigateToFeature('Health Monitoring'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.notifications_outlined,
                    title: 'Reminders',
                    backgroundColor: customOrange,
                    iconColor: Colors.white,
                    onTap: () => _navigateToFeature('Reminders'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.restaurant_outlined,
                    title: 'Meal Plans',
                    backgroundColor: const Color(0xFFF5E6D0),
                    iconColor: Colors.black,
                    onTap: () => _navigateToFeature('Meal Plans'),
                  ),
                ),
                const Expanded(child: SizedBox()),
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
            Icon(
              icon,
              size: 30,
              color: iconColor,
            ),
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
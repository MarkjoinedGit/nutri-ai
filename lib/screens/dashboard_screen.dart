import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './chat_consultant_screen.dart';
import './calorie_tracking_screen.dart';
import './health_monitoring_screen.dart';
import './recipe_recognition_screen.dart';
import './reminder_screen.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../utils/app_strings.dart';

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

      final localizationProvider = Provider.of<LocalizationProvider>(
        context,
        listen: false,
      );
      final strings = AppStrings.getStrings(
        localizationProvider.currentLanguage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${strings.logoutError}: ${e.toString()}')),
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
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.userNotLoggedIn)));
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
          MaterialPageRoute(builder: (context) => const RemindersScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$feature ${strings.comingSoon}')),
        );
    }
  }

  void _showLanguageBottomSheet() {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                strings.language,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(strings.vietnamese),
                trailing:
                    localizationProvider.isVietnamese
                        ? Icon(Icons.check, color: customOrange)
                        : null,
                onTap: () {
                  localizationProvider.changeLanguage('vi');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(strings.english),
                trailing:
                    localizationProvider.isEnglish
                        ? Icon(Icons.check, color: customOrange)
                        : null,
                onTap: () {
                  localizationProvider.changeLanguage('en');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, LocalizationProvider>(
      builder: (context, userProvider, localizationProvider, child) {
        final user = userProvider.currentUser;
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.apple, color: customOrange),
                const SizedBox(width: 8),
                Text(
                  strings.appTitle,
                  style: const TextStyle(
                    color: customOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            actions: [
              IconButton(
                icon: const Icon(Icons.language, color: Colors.black87),
                onPressed: _showLanguageBottomSheet,
              ),
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
                  ? Center(child: Text(strings.noUserData))
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            '${strings.welcomeUser}, ${user.name}',
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
                                strings.healthcareProfessional,
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
                                title: strings.chatConsultation,
                                backgroundColor: const Color(0xFFF5E6D0),
                                iconColor: Colors.black,
                                onTap:
                                    () =>
                                        _navigateToFeature('Chat Consultation'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.camera_alt_outlined,
                                title: strings.recipeRecognition,
                                backgroundColor: Colors.grey.shade300,
                                iconColor: Colors.black,
                                onTap:
                                    () => _navigateToFeature(
                                      'Recipe Recognition',
                                    ),
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
                                title: strings.calorieTracking,
                                backgroundColor: customOrange,
                                iconColor: Colors.white,
                                onTap:
                                    () =>
                                        _navigateToFeature('Calorie Tracking'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.favorite_border,
                                title: strings.healthMonitoring,
                                backgroundColor: const Color(0xFFF5E6D0),
                                iconColor: Colors.black,
                                onTap:
                                    () =>
                                        _navigateToFeature('Health Monitoring'),
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
                                title: strings.reminders,
                                backgroundColor: Colors.grey.shade300,
                                iconColor: Colors.black,
                                onTap: () => _navigateToFeature('Reminders'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child:
                                  Container(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                label: strings.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.notifications_outlined),
                label: strings.notifications,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: strings.user,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: customOrange,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        );
      },
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

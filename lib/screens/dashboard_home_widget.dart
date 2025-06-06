import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './chat_consultant_screen.dart';
import './calorie_tracking_screen.dart';
import './health_monitoring_screen.dart';
import './recipe_recognition_screen.dart';
import './reminder_screen.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../utils/app_strings.dart';

class DashboardHomeWidget extends StatelessWidget {
  const DashboardHomeWidget({super.key});

  static const Color customOrange = Color(0xFFE07E02);

  void _navigateToFeature(BuildContext context, String feature) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, LocalizationProvider>(
      builder: (context, userProvider, localizationProvider, child) {
        final user = userProvider.currentUser;
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return user == null
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
                          context: context,
                          icon: Icons.chat_bubble_outline,
                          title: strings.chatConsultation,
                          backgroundColor: const Color(0xFFF5E6D0),
                          iconColor: Colors.black,
                          onTap:
                              () => _navigateToFeature(
                                context,
                                'Chat Consultation',
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          context: context,
                          icon: Icons.camera_alt_outlined,
                          title: strings.recipeRecognition,
                          backgroundColor: Colors.grey.shade300,
                          iconColor: Colors.black,
                          onTap:
                              () => _navigateToFeature(
                                context,
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
                          context: context,
                          icon: Icons.analytics_outlined,
                          title: strings.calorieTracking,
                          backgroundColor: customOrange,
                          iconColor: Colors.white,
                          onTap:
                              () => _navigateToFeature(
                                context,
                                'Calorie Tracking',
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          context: context,
                          icon: Icons.favorite_border,
                          title: strings.healthMonitoring,
                          backgroundColor: const Color(0xFFF5E6D0),
                          iconColor: Colors.black,
                          onTap:
                              () => _navigateToFeature(
                                context,
                                'Health Monitoring',
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
                          context: context,
                          icon: Icons.notifications_outlined,
                          title: strings.reminders,
                          backgroundColor: Colors.grey.shade300,
                          iconColor: Colors.black,
                          onTap: () => _navigateToFeature(context, 'Reminders'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Container()),
                    ],
                  ),
                ],
              ),
            );
      },
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
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

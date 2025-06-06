import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './health_monitoring_screen.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../utils/app_strings.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key});

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  static const Color customOrange = Color(0xFFE07E02);

  Future<void> _logout() async {
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
    }
  }

  void _navigateToHealthMonitoring() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthMonitoringScreen()),
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
            title: Text(
              strings.user,
              style: const TextStyle(
                color: customOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body:
              user == null
                  ? Center(child: Text(strings.noUserData))
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: customOrange.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: customOrange,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (user.isDoctor)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
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
                        const SizedBox(height: 30),
                        _buildProfileItem(
                          icon: Icons.medical_services,
                          title: strings.healthRecords,
                          onTap: _navigateToHealthMonitoring,
                        ),
                        _buildProfileItem(
                          icon: Icons.logout,
                          title: strings.logout,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: customOrange),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

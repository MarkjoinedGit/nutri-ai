import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './dashboard_home_widget.dart';
import './user_profile_widget.dart';
import './notification_screen.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/notification_provider.dart';
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

  final List<Widget> _screens = [
    const DashboardHomeWidget(),
    const NotificationScreen(),
    const UserProfileWidget(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addDemoNotifications();
    });
  }

  void _addDemoNotifications() {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    notificationProvider.addNotification(
      id: 1,
      title: 'Reminder: Take your vitamins',
      body: 'Time to take your daily vitamins for better health!',
    );

    notificationProvider.addNotification(
      id: 2,
      title: 'Meal tracking reminder',
      body: "Don't forget to log your lunch today.",
    );

    notificationProvider.addNotification(
      id: 3,
      title: 'Health tip of the day',
      body:
          'Drinking water first thing in the morning can boost your metabolism.',
    );
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
    return Consumer3<UserProvider, LocalizationProvider, NotificationProvider>(
      builder: (
        context,
        userProvider,
        localizationProvider,
        notificationProvider,
        child,
      ) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar:
              _selectedIndex == 0
                  ? AppBar(
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
                  )
                  : null,
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                label: strings.home,
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined),
                    if (notificationProvider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${notificationProvider.unreadCount > 99 ? '99+' : notificationProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
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
          floatingActionButton:
              _selectedIndex == 0
                  ? FloatingActionButton(
                    onPressed: () {
                      NotificationService().showInstantNotification(
                        id: DateTime.now().millisecondsSinceEpoch,
                        title: 'Test Notification',
                        body: 'This is a test notification from the app!',
                      );
                    },
                    backgroundColor: customOrange,
                    child: const Icon(Icons.add_alert, color: Colors.white),
                  )
                  : null,
        );
      },
    );
  }
}

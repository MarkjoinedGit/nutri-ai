import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'providers/chat_provider.dart';
import 'providers/user_provider.dart';
import 'providers/calorie_tracking_provider.dart';
import 'providers/medical_record_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/notification_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CalorieTrackingProvider()),
        ChangeNotifierProvider(create: (_) => MedicalRecordProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const NutriAI(),
    ),
  );
}

class NutriAI extends StatelessWidget {
  const NutriAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE07E02)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      if (!mounted) return;

      final localizationProvider = Provider.of<LocalizationProvider>(
        context,
        listen: false,
      );
      await localizationProvider.loadLanguage();

      if (!mounted) return;

      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      await notificationProvider.initialize();

      NotificationService().setNotificationProvider(notificationProvider);

      await _addSampleNotificationsIfNeeded(notificationProvider);

      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isAuthenticated = await userProvider.loadUserFromPrefs();

      if (mounted) {
        setState(() {
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addSampleNotificationsIfNeeded(
    NotificationProvider provider,
  ) async {
    if (provider.notifications.isEmpty) {
      await provider.addNotification(
        id: 1,
        title: 'Welcome to NutriAI!',
        body: 'Start your healthy journey with us today',
      );

      await provider.addNotification(
        id: 2,
        title: 'Daily Reminder',
        body: 'Don\'t forget to log your meals and track your progress',
      );

      await provider.addNotification(
        id: 3,
        title: 'Health Tip',
        body: 'Drink at least 8 glasses of water daily for better health',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFE07E02)),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: Color(0xFFE07E02), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return _isAuthenticated ? const DashboardScreen() : const WelcomeScreen();
  }
}

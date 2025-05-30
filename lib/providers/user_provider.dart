import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null && _currentUser!.isValid;
  
  bool get isDoctor => _currentUser?.isDoctor ?? false;

  Future<bool> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) {
      _currentUser = null;
      return false;
    }

    _currentUser = User(
      id: prefs.getString('userId') ?? '',
      name: prefs.getString('name') ?? '',
      email: prefs.getString('email') ?? '',
      isDoctor: prefs.getBool('isDoctor') ?? false,
    );
    
    notifyListeners();
    return _currentUser!.isValid;
  }

  Future<void> saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('userId', user.id);
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    await prefs.setBool('isDoctor', user.isDoctor);
    await prefs.setBool('isLoggedIn', true);
    
    _currentUser = user;
    notifyListeners();
  }

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _currentUser = null;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';

class UserManager extends ChangeNotifier {
  UserManager._();
  static final UserManager _instance = UserManager._();
  static UserManager get instance => _instance;

  String _name = 'Guest';
  String _email = 'guest@unitask.com';
  String _role = 'User';
  bool _isLoggedIn = false;

  String get name => _name;
  String get email => _email;
  String get role => _role;
  bool get isLoggedIn => _isLoggedIn;

  void login(String email, String password) {
    // Simulate login
    _email = email;
    _name = email.split('@')[0]; // Use part of email as name for now
    _role = 'Member';
    _isLoggedIn = true;
    notifyListeners();
  }

  void loginAsGuest() {
    _email = 'guest@unitask.com';
    _name = 'Guest User';
    _role = 'Guest';
    _isLoggedIn = true;
    notifyListeners();
  }

  void register(String name, String email, String password) {
    // Simulate register
    _name = name;
    _email = email;
    _role = 'Member';
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _name = 'Guest';
    _email = 'guest@unitask.com';
    _role = 'User';
    _isLoggedIn = false;
    notifyListeners();
  }

  void updateProfile({String? name, String? role}) {
    if (name != null) _name = name;
    if (role != null) _role = role;
    notifyListeners();
  }
}

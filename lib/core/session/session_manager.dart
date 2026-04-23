import 'package:flutter/foundation.dart';
import '../model/user_model.dart';

class SessionManager extends ChangeNotifier {
  SessionManager._();
  static final SessionManager instance = SessionManager._();
  factory SessionManager() => instance;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void login(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  bool canAccess(UserRole module) {
    if (_currentUser == null) return false;
    if (_currentUser!.role == UserRole.admin) return true;
    return _currentUser!.role == module;
  }
}

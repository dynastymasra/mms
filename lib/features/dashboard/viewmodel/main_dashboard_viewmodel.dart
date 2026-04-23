import 'package:flutter/material.dart';
import '../../../core/model/user_model.dart';
import '../../../core/session/session_manager.dart';

class MainDashboardViewModel extends ChangeNotifier {
  final _session = SessionManager();

  UserModel get currentUser => _session.currentUser!;

  bool get canAccessAdmin => _session.canAccess(UserRole.admin);
  bool get canAccessInventory => _session.canAccess(UserRole.inventory);
  bool get canAccessZiswaf => _session.canAccess(UserRole.ziswaf);

  void logout(BuildContext context) {
    _session.logout();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

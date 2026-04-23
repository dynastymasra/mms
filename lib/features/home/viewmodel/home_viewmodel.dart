import 'package:flutter/material.dart';
import '../../auth/view/user_select_screen.dart';
import '../../dashboard/view/main_dashboard_screen.dart';

class HomeViewModel extends ChangeNotifier {
  void onLoginTapped(BuildContext context) {
    showUserSelectDialog(
      context,
      onSuccess: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
      ),
    );
  }
}

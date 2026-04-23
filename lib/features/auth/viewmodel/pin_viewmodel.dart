import 'package:flutter/material.dart';
import '../../../core/model/user_model.dart';
import '../../../core/session/session_manager.dart';

class PinViewModel extends ChangeNotifier {
  PinViewModel({required this.user});

  final UserModel user;
  static const maxLength = 6;

  String _pin = '';
  bool _hasError = false;

  String get pin => _pin;
  bool get hasError => _hasError;
  bool get isFilled => _pin.length == maxLength;

  void appendDigit(String digit) {
    if (_pin.length >= maxLength) return;
    _pin += digit;
    _hasError = false;
    notifyListeners();
  }

  void deleteLast() {
    if (_pin.isEmpty) return;
    _pin = _pin.substring(0, _pin.length - 1);
    _hasError = false;
    notifyListeners();
  }

  bool validate() {
    if (_pin == user.pin) {
      SessionManager().login(user);
      return true;
    }
    _hasError = true;
    _pin = '';
    notifyListeners();
    return false;
  }
}

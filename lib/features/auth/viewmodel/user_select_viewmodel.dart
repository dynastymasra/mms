import 'package:flutter/material.dart';
import '../../../core/data/user_repository.dart';
import '../../../core/model/user_model.dart';

class UserSelectViewModel extends ChangeNotifier {
  UserSelectViewModel() {
    _allUsers = UserRepository().allUsers.toList();
    _filtered = List.of(_allUsers);
  }

  late List<UserModel> _allUsers;
  late List<UserModel> _filtered;

  List<UserModel> get users => _filtered;

  void search(String query) {
    final q = query.trim().toLowerCase();
    _filtered = q.isEmpty
        ? List.of(_allUsers)
        : _allUsers.where((u) => u.name.toLowerCase().contains(q)).toList();
    notifyListeners();
  }
}

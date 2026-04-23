import 'package:flutter/material.dart';
import '../../../core/data/user_repository.dart';
import '../../../core/model/user_model.dart';

class UserManagementViewModel extends ChangeNotifier {
  final _repo = UserRepository();

  List<UserModel> _all = [];
  List<UserModel> _filtered = [];
  String _query = '';

  List<UserModel> get users => _filtered;

  UserManagementViewModel() {
    _reload();
  }

  void _reload() {
    _all = _repo.allUsers.toList();
    _applyFilter();
  }

  void _applyFilter() {
    final q = _query.toLowerCase();
    _filtered = q.isEmpty
        ? List.of(_all)
        : _all.where((u) => u.name.toLowerCase().contains(q)).toList();
    notifyListeners();
  }

  void search(String query) {
    _query = query.trim();
    _applyFilter();
  }

  void addUser({
    required String name,
    required UserRole role,
    required String pin,
  }) {
    _repo.addUser(UserModel(
      id: _repo.generateId(),
      name: name,
      role: role,
      pin: pin,
    ));
    _reload();
  }

  void updateUser(UserModel updated) {
    _repo.updateUser(updated);
    _reload();
  }

  void removeUser(String id) {
    _repo.removeUser(id);
    _reload();
  }
}

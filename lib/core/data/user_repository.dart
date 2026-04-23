import '../model/user_model.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();
  factory UserRepository() => instance;

  final List<UserModel> _users = [
    const UserModel(id: '1', name: 'Dimas ', role: UserRole.admin, pin: '123456'),
    const UserModel(id: '2', name: 'Nugroho', role: UserRole.admin, pin: '654321'),
    const UserModel(id: '3', name: 'Dani', role: UserRole.inventory, pin: '111222'),
    const UserModel(id: '4', name: 'Rival', role: UserRole.inventory, pin: '333444'),
  ];

  List<UserModel> get allUsers => List.unmodifiable(_users);

  List<UserModel> getUsersByRole(UserRole role) =>
      _users.where((u) => u.role == role).toList();

  List<UserModel> getUsersForModule(UserRole module) {
    if (module == UserRole.admin) {
      return _users.where((u) => u.role == UserRole.admin).toList();
    }
    return _users
        .where((u) => u.role == UserRole.admin || u.role == module)
        .toList();
  }

  void addUser(UserModel user) => _users.add(user);

  void removeUser(String id) => _users.removeWhere((u) => u.id == id);

  void updateUser(UserModel updated) {
    final i = _users.indexWhere((u) => u.id == updated.id);
    if (i != -1) _users[i] = updated;
  }

  String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}

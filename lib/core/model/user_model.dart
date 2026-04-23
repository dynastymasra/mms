enum UserRole { admin, inventory, ziswaf }

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.pin,
    this.initials,
  });

  final String id;
  final String name;
  final UserRole role;
  final String pin;
  final String? initials;

  String get displayInitials =>
      initials ??
      name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();

  UserModel copyWith({
    String? name,
    UserRole? role,
    String? pin,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      pin: pin ?? this.pin,
    );
  }
}

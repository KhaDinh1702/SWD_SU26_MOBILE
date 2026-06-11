class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        email: (json['email'] ?? json['username'] ?? '').toString(),
        name: (json['name'] ?? json['fullName'] ?? json['username'] ?? '')
            .toString(),
        role: (json['role'] ?? json['type'] ?? '').toString(),
      );

  /// True nếu tài khoản là thợ rửa xe (washer/staff).
  bool get isWasher {
    final r = role.toLowerCase();
    return r.contains('wash') ||
        r == 'staff' ||
        r == 'employee' ||
        r == 'worker';
  }
}

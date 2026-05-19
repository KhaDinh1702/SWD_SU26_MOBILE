class UserModel {
  final String id;
  final String email;
  final String name;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] ?? json['_id'] ?? '') as String,
        email: json['email'] as String,
        name: (json['name'] ?? json['username'] ?? '') as String,
      );
}

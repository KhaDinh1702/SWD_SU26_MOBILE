class ProfileModel {
  final String id;
  final String name;
  final String email;
  final int loyaltyPoints;
  final String tier;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.loyaltyPoints,
    required this.tier,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      tier: json['tier'] ?? 'ĐỒNG',
    );
  }
}

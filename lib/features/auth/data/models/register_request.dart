class RegisterRequest {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String dateOfBirth;

  const RegisterRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'dateOfBirth': dateOfBirth,
      };
}

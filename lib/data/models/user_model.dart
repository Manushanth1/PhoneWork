class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'User',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}

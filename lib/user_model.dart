class User {
  String displayName;
  String email;
  String phoneNumber;

  User({
    required this.displayName,
    required this.email,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      displayName: json['displayName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class User {
  int? id;
  String username;
  String password; // ideally hashed
  String role; // "admin" or "user"

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  // Convert object → Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'role': role,
    };
  }

  // Convert Map → object
  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      role: json['role'],
    );
  }
}

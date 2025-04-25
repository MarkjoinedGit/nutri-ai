class User {
  final String id;
  final String name;
  final String email;
  final bool isDoctor;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isDoctor,
  });

  // Create a User from JSON (useful when receiving data from API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isDoctor: json['isDoctor'] ?? false,
    );
  }

  // Convert User to JSON (useful when storing data)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isDoctor': isDoctor,
    };
  }

  // Create a User from SharedPreferences
  factory User.fromPrefs(Map<String, dynamic> prefs) {
    return User(
      id: prefs['userId'] ?? '',
      name: prefs['name'] ?? '',
      email: prefs['email'] ?? '',
      isDoctor: prefs['isDoctor'] ?? false,
    );
  }

  // Check if the user instance is valid
  bool get isValid => id.isNotEmpty && email.isNotEmpty;
}
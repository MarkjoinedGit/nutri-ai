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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isDoctor: json['isDoctor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'isDoctor': isDoctor};
  }

  factory User.fromPrefs(Map<String, dynamic> prefs) {
    return User(
      id: prefs['userId'] ?? '',
      name: prefs['name'] ?? '',
      email: prefs['email'] ?? '',
      isDoctor: prefs['isDoctor'] ?? false,
    );
  }

  bool get isValid => id.isNotEmpty && email.isNotEmpty;
}

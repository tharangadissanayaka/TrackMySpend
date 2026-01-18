import 'report.dart';

class User {
  String id;
  String name;
  String email;
  Map<String, dynamic> preferences;

  // Relationship User can generate many reports
  List<Report> reports = [];

  User({
    required this.id,
    required this.name,
    required this.email,
    this.preferences = const {},
  });

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      preferences: json['preferences'] ?? {},
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
    };
  }

  void register() {
    print("User $name registered successfully!");
  }

  bool login(String enteredEmail, String enteredPassword) {
    print("Login successful for $name");
    return true;
  }

  void logout() {
    print("User $name logged out.");
  }

  void addReport(Report report) {
    reports.add(report);
  }
}

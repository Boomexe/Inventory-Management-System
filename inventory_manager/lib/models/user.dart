class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final List<String> assignedItems;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.assignedItems,
  });

  factory User.fromJson(Map<String, dynamic> json, String password) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: password,
      assignedItems: json['assigned_items'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'assigned_items': assignedItems,
    };
  }
}

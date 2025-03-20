class User {
  final int id;
  final String? email;
  final String name;
  final String? phoneNumber;
  final String role;
  
  User({
    required this.id,
    this.email,
    required this.name,
    this.phoneNumber,
    required this.role,
  });
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      role: map['role'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }
}


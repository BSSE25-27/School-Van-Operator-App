class Driver {
  final String id;
  final String name;
  final String phoneNumber;
  final String? profileImageUrl;
  final String? assignedVanId;
  
  Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.profileImageUrl,
    this.assignedVanId,
  });
  
  factory Driver.fromMap(Map<String, dynamic> map, String id) {
    return Driver(
      id: id,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      assignedVanId: map['assignedVanId'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'assignedVanId': assignedVanId,
    };
  }
}


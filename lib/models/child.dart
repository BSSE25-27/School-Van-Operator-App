class Child {
  final String id;
  final String name;
  final String? guardianName;
  final String? guardianPhone;
  final String? vanId;
  final bool isPresent;
  final String? qrCode;
  final String? eta;
  
  Child({
    required this.id,
    required this.name,
    this.guardianName,
    this.guardianPhone,
    this.vanId,
    this.isPresent = false,
    this.qrCode,
    this.eta,
  });
  
  factory Child.fromMap(Map<String, dynamic> map, String id) {
    return Child(
      id: id,
      name: map['name'] ?? '',
      guardianName: map['guardianName'],
      guardianPhone: map['guardianPhone'],
      vanId: map['vanId'],
      isPresent: map['isPresent'] ?? false,
      qrCode: map['qrCode'],
      eta: map['eta'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'vanId': vanId,
      'isPresent': isPresent,
      'qrCode': qrCode,
      'eta': eta,
    };
  }
  
  Child copyWith({
    String? id,
    String? name,
    String? guardianName,
    String? guardianPhone,
    String? vanId,
    bool? isPresent,
    String? qrCode,
    String? eta,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      vanId: vanId ?? this.vanId,
      isPresent: isPresent ?? this.isPresent,
      qrCode: qrCode ?? this.qrCode,
      eta: eta ?? this.eta,
    );
  }
}


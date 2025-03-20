class Van {
  final String id;
  final String numberPlate;
  final List<String> routes;
  final int assignedChildrenCount;
  final String? driverId;
  
  Van({
    required this.id,
    required this.numberPlate,
    required this.routes,
    required this.assignedChildrenCount,
    this.driverId,
  });
  
  factory Van.fromMap(Map<String, dynamic> map, String id) {
    return Van(
      id: id,
      numberPlate: map['numberPlate'] ?? '',
      routes: List<String>.from(map['routes'] ?? []),
      assignedChildrenCount: map['assignedChildrenCount'] ?? 0,
      driverId: map['driverId'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'numberPlate': numberPlate,
      'routes': routes,
      'assignedChildrenCount': assignedChildrenCount,
      'driverId': driverId,
    };
  }
}


class BusRoute {
  final String id;
  final String name;
  final String startLocation;
  final String endLocation;
  final int estimatedTimeMinutes;
  final double distanceKm;
  final String? comingFrom;
  
  BusRoute({
    required this.id,
    required this.name,
    required this.startLocation,
    required this.endLocation,
    required this.estimatedTimeMinutes,
    required this.distanceKm,
    this.comingFrom,
  });
  
  factory BusRoute.fromMap(Map<String, dynamic> map, String id) {
    return BusRoute(
      id: id,
      name: map['name'] ?? '',
      startLocation: map['startLocation'] ?? '',
      endLocation: map['endLocation'] ?? '',
      estimatedTimeMinutes: map['estimatedTimeMinutes'] ?? 0,
      distanceKm: map['distanceKm'] ?? 0.0,
      comingFrom: map['comingFrom'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'estimatedTimeMinutes': estimatedTimeMinutes,
      'distanceKm': distanceKm,
      'comingFrom': comingFrom,
    };
  }
}


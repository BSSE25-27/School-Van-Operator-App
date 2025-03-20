class Trip {
  final String id;
  final String vanId;
  final String driverId;
  final String routeId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final double? lat; // Latitude for location
  final double? lng; // Longitude for location
  final String? eta;
  final bool hasReachedDestination;
  final bool isNearDestination;
  final int? minutesAway;
  final bool hasTrafficAlert;

  Trip({
    required this.id,
    required this.vanId,
    required this.driverId,
    required this.routeId,
    required this.startTime,
    this.endTime,
    this.isActive = true,
    this.lat,
    this.lng,
    this.eta,
    this.hasReachedDestination = false,
    this.isNearDestination = false,
    this.minutesAway,
    this.hasTrafficAlert = false,
  });

  // Convert from MySQL result (Map<String, dynamic>) to object
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'].toString(),
      vanId: map['vanId'] ?? '',
      driverId: map['driverId'] ?? '',
      routeId: map['routeId'] ?? '',
      startTime: DateTime.parse(
          map['startTime']), // Convert MySQL DATETIME string to DateTime
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      isActive:
          map['isActive'] == 1, // MySQL stores booleans as tinyint (0 or 1)
      lat: map['lat'] != null ? double.parse(map['lat'].toString()) : null,
      lng: map['lng'] != null ? double.parse(map['lng'].toString()) : null,
      eta: map['eta'],
      hasReachedDestination: map['hasReachedDestination'] == 1,
      isNearDestination: map['isNearDestination'] == 1,
      minutesAway: map['minutesAway'],
      hasTrafficAlert: map['hasTrafficAlert'] == 1,
    );
  }

  // Convert object to MySQL-compatible format
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vanId': vanId,
      'driverId': driverId,
      'routeId': routeId,
      'startTime': startTime.toIso8601String(), // Convert DateTime to string
      'endTime': endTime?.toIso8601String(),
      'isActive': isActive ? 1 : 0, // Convert boolean to tinyint (1 or 0)
      'lat': lat,
      'lng': lng,
      'eta': eta,
      'hasReachedDestination': hasReachedDestination ? 1 : 0,
      'isNearDestination': isNearDestination ? 1 : 0,
      'minutesAway': minutesAway,
      'hasTrafficAlert': hasTrafficAlert ? 1 : 0,
    };
  }

  Trip copyWith({
    String? id,
    String? vanId,
    String? driverId,
    String? routeId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    double? lat,
    double? lng,
    String? eta,
    bool? hasReachedDestination,
    bool? isNearDestination,
    int? minutesAway,
    bool? hasTrafficAlert,
  }) {
    return Trip(
      id: id ?? this.id,
      vanId: vanId ?? this.vanId,
      driverId: driverId ?? this.driverId,
      routeId: routeId ?? this.routeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      eta: eta ?? this.eta,
      hasReachedDestination:
          hasReachedDestination ?? this.hasReachedDestination,
      isNearDestination: isNearDestination ?? this.isNearDestination,
      minutesAway: minutesAway ?? this.minutesAway,
      hasTrafficAlert: hasTrafficAlert ?? this.hasTrafficAlert,
    );
  }
}

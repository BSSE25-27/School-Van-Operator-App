class TripNotification {
  final String id;
  final String driverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'destination', 'proximity', 'traffic', 'general'

  TripNotification({
    required this.id,
    required this.driverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  factory TripNotification.fromMap(Map<String, dynamic> map) {
    return TripNotification(
      id: map['id'].toString(),
      driverId: map['driverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.parse(
          map['timestamp']), // MySQL stores timestamps as strings
      isRead: map['isRead'] == 1, // MySQL stores booleans as tinyint (0 or 1)
      type: map['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to string
      'isRead': isRead ? 1 : 0, // Convert boolean to tinyint (1 or 0)
      'type': type,
    };
  }

  TripNotification copyWith({
    String? id,
    String? driverId,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
  }) {
    return TripNotification(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

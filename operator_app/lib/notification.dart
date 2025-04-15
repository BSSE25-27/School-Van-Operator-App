import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] == 1,
      type: map['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
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

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'destination':
        return Icons.location_on_outlined;
      case 'proximity':
        return Icons.directions_bus;
      case 'traffic':
        return Icons.traffic;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat.yMMMd().add_jm().format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for now
    final List<TripNotification> notifications = [
      TripNotification(
        id: '1',
        driverId: 'D1',
        message: 'Bus is nearing your pickup point.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        type: 'proximity',
      ),
      TripNotification(
        id: '2',
        driverId: 'D1',
        message: 'Bus has reached the school.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
        type: 'destination',
      ),
      TripNotification(
        id: '3',
        driverId: 'D1',
        message: 'Heavy traffic on the usual route.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        type: 'traffic',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          notifications.isEmpty
              ? const Center(child: Text("No notifications yet."))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getIconForType(notification.type),
                        color:
                            notification.isRead
                                ? Colors.grey
                                : Colors.deepPurple,
                      ),
                      title: Text(
                        notification.message,
                        style: TextStyle(
                          fontWeight:
                              notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(_formatTimestamp(notification.timestamp)),
                      trailing:
                          notification.isRead
                              ? null
                              : const Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.deepPurple,
                              ),
                      onTap: () {
                        // You can add logic to mark as read here
                      },
                    ),
                  );
                },
              ),
    );
  }
}

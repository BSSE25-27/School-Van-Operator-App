import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver.dart';
import '../models/van.dart';
import '../models/child.dart';
import '../models/route.dart';
import '../models/trip.dart';
import '../models/notification.dart';
import '../models/user.dart';

class ApiDatabaseService {
  final String baseUrl = 'http://localhost:8080/api';
  final http.Client _client = http.Client();

  // Authentication methods
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Email and password cannot be empty',
        };
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      print(data);

      if (response.statusCode == 200) {
        User user = User(
          id: data['user']['id'],
          email: data['user']['email'],
          name: data['user']['name'],
          role: data['user']['role'],
          phoneNumber: data['user']['phoneNumber'],
        );

        return {
          'success': true,
          'message': 'Login successful',
          'user': data["user"]
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid email or password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      // Validate phone number
      if (phoneNumber.isEmpty) {
        return {
          'success': false,
          'message': 'Phone number cannot be empty',
        };
      }

      // Format phone number if needed
      if (!phoneNumber.startsWith('+')) {
        phoneNumber =
            '+256$phoneNumber'; // Assuming Uganda as default country code
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP sent successfully',
          'otp': data['otp'], // In production, the API shouldn't return this
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      // Validate OTP
      if (otp.isEmpty || otp.length != 4) {
        return {
          'success': false,
          'message': 'Please enter a valid 4-digit OTP',
        };
      }

      // Format phone number if needed
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+256$phoneNumber';
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'userData': data['userData'],
          'message': 'OTP verification successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid or expired OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  // Driver methods
  Future<Driver?> getDriverById(String driverId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/drivers/$driverId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Driver(
          id: data['id'],
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          profileImageUrl: data['profileImageUrl'],
          assignedVanId: data['assignedVanId'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting driver: $e');
      return null;
    }
  }

  Future<Driver?> getDriverByUserId(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/drivers/user/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Driver(
          id: data['id'],
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          profileImageUrl: data['profileImageUrl'],
          assignedVanId: data['assignedVanId'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting driver by user ID: $e');
      return null;
    }
  }

  Future<void> updateDriver(Driver driver) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/drivers/${driver.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': driver.name,
          'phoneNumber': driver.phoneNumber,
          'profileImageUrl': driver.profileImageUrl,
          'assignedVanId': driver.assignedVanId,
        }),
      );
    } catch (e) {
      print('Error updating driver: $e');
      rethrow;
    }
  }

  // Van methods
  Future<Van?> getVanById(String vanId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/vans/$vanId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Van(
          id: data['id'],
          numberPlate: data['numberPlate'],
          routes: List<String>.from(data['routes']),
          assignedChildrenCount: data['assignedChildrenCount'],
          driverId: data['driverId'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting van: $e');
      return null;
    }
  }

  Future<Van?> getVanByDriverId(String driverId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/vans/driver/$driverId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Van(
          id: data['id'],
          numberPlate: data['numberPlate'],
          routes: List<String>.from(data['routes']),
          assignedChildrenCount: data['assignedChildrenCount'],
          driverId: data['driverId'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting van by driver ID: $e');
      return null;
    }
  }

  // Children methods
  Future<List<Child>> getChildrenByVanId(String vanId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/children/van/$vanId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => Child(
                  id: item['id'],
                  name: item['name'],
                  guardianName: item['guardianName'],
                  guardianPhone: item['guardianPhone'],
                  vanId: item['vanId'],
                  isPresent: item['isPresent'],
                  qrCode: item['qrCode'],
                  eta: item['eta'],
                ))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting children by van ID: $e');
      return [];
    }
  }

  Future<void> updateChildAttendance(String childId, bool isPresent) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/children/$childId/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'isPresent': isPresent,
        }),
      );
    } catch (e) {
      print('Error updating child attendance: $e');
      rethrow;
    }
  }

  Future<void> updateChildEta(String childId, String eta) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/children/$childId/eta'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'eta': eta,
        }),
      );
    } catch (e) {
      print('Error updating child ETA: $e');
      rethrow;
    }
  }

  // Routes methods
  Future<List<BusRoute>> getRoutesByStartAndEnd(
      String startLocation, String endLocation) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/routes?start=$startLocation&end=$endLocation'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => BusRoute(
                  id: item['id'],
                  name: item['name'],
                  startLocation: item['startLocation'],
                  endLocation: item['endLocation'],
                  estimatedTimeMinutes: item['estimatedTimeMinutes'],
                  distanceKm: item['distanceKm'],
                  comingFrom: item['comingFrom'],
                ))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting routes: $e');
      return [];
    }
  }

  Future<BusRoute?> getRouteById(String routeId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/routes/$routeId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BusRoute(
          id: data['id'],
          name: data['name'],
          startLocation: data['startLocation'],
          endLocation: data['endLocation'],
          estimatedTimeMinutes: data['estimatedTimeMinutes'],
          distanceKm: data['distanceKm'],
          comingFrom: data['comingFrom'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }

  // Trip methods
  Future<String> startTrip(Trip trip) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/trips'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vanId': trip.vanId,
          'driverId': trip.driverId,
          'routeId': trip.routeId,
          'startTime': trip.startTime.toIso8601String(),
          'isActive': trip.isActive,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      }
      throw Exception('Failed to start trip');
    } catch (e) {
      print('Error starting trip: $e');
      rethrow;
    }
  }

  Future<void> endTrip(String tripId) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/trips/$tripId/end'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error ending trip: $e');
      rethrow;
    }
  }

  Future<void> updateTripLocation(
      String tripId, double latitude, double longitude) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/trips/$tripId/location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
    } catch (e) {
      print('Error updating trip location: $e');
      rethrow;
    }
  }

  Future<void> updateTripEta(String tripId, String eta) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/trips/$tripId/eta'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'eta': eta,
        }),
      );
    } catch (e) {
      print('Error updating trip ETA: $e');
      rethrow;
    }
  }

  Future<Trip?> getActiveTrip(String driverId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/trips/active/driver/$driverId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Trip(
          id: data['id'],
          vanId: data['vanId'],
          driverId: data['driverId'],
          routeId: data['routeId'],
          startTime: DateTime.parse(data['startTime']),
          endTime:
              data['endTime'] != null ? DateTime.parse(data['endTime']) : null,
          isActive: data['isActive'],
          lat: data['latitude'],
          lng: data['longitude'],
          eta: data['eta'],
          hasReachedDestination: data['hasReachedDestination'],
          isNearDestination: data['isNearDestination'],
          minutesAway: data['minutesAway'],
          hasTrafficAlert: data['hasTrafficAlert'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting active trip: $e');
      return null;
    }
  }

  // Trip alert methods
  Future<void> updateTripProximityStatus(
      String tripId, bool isNearDestination, int? minutesAway) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/trips/$tripId/proximity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'isNearDestination': isNearDestination,
          'minutesAway': minutesAway,
        }),
      );
    } catch (e) {
      print('Error updating trip proximity status: $e');
      rethrow;
    }
  }

  Future<void> updateTripDestinationStatus(
      String tripId, bool hasReached) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/trips/$tripId/destination'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'hasReached': hasReached,
        }),
      );
    } catch (e) {
      print('Error updating trip destination status: $e');
      rethrow;
    }
  }

  Future<void> updateTripTrafficAlert(
      String tripId, bool hasTrafficAlert) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/trips/$tripId/traffic'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'hasTrafficAlert': hasTrafficAlert,
        }),
      );
    } catch (e) {
      print('Error updating trip traffic alert: $e');
      rethrow;
    }
  }

  // Notification methods
  Future<String> createNotification(TripNotification notification) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'driverId': notification.driverId,
          'message': notification.message,
          'timestamp': notification.timestamp.toIso8601String(),
          'isRead': notification.isRead,
          'type': notification.type,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      }
      throw Exception('Failed to create notification');
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  Future<List<TripNotification>> getNotificationsByDriverId(
      String driverId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/notifications/driver/$driverId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => TripNotification(
                  id: item['id'],
                  driverId: item['driverId'],
                  message: item['message'],
                  timestamp: DateTime.parse(item['timestamp']),
                  isRead: item['isRead'],
                  type: item['type'],
                ))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }
}

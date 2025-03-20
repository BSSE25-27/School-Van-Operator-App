import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../models/van.dart';
import '../models/child.dart';
import '../models/route.dart';
import '../models/trip.dart';
import '../models/notification.dart';
import '../services/mysql_database_service.dart';

class MySqlAppProvider with ChangeNotifier {
  final ApiDatabaseService _databaseService;

  Driver? _currentDriver;
  Van? _assignedVan;
  List<Child> _children = [];
  List<BusRoute> _routes = [];
  Trip? _activeTrip;
  List<TripNotification> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  MySqlAppProvider(this._databaseService);

  // Getters
  Driver? get currentDriver => _currentDriver;
  Van? get assignedVan => _assignedVan;
  List<Child> get children => _children;
  List<BusRoute> get routes => _routes;
  Trip? get activeTrip => _activeTrip;
  List<TripNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Load driver data
  Future<void> loadDriverData(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get driver by user ID
      _currentDriver = await _databaseService.getDriverByUserId(userId);

      if (_currentDriver != null && _currentDriver!.assignedVanId != null) {
        // Get assigned van
        _assignedVan =
            await _databaseService.getVanById(_currentDriver!.assignedVanId!);

        // Get children assigned to van
        if (_assignedVan != null) {
          _children =
              await _databaseService.getChildrenByVanId(_assignedVan!.id);
        }

        // Get active trip
        _activeTrip = await _databaseService.getActiveTrip(_currentDriver!.id);

        // Get notifications
        _notifications = await _databaseService
            .getNotificationsByDriverId(_currentDriver!.id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading driver data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get routes
  Future<void> getRoutes(String startLocation, String endLocation) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _routes = await _databaseService.getRoutesByStartAndEnd(
          startLocation, endLocation);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading routes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start trip
  Future<bool> startTrip(String routeId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (_currentDriver == null || _assignedVan == null) {
        _errorMessage = 'Driver or van data not available';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      Trip newTrip = Trip(
        id: '', // Will be set by MySQL
        vanId: _assignedVan!.id,
        driverId: _currentDriver!.id,
        routeId: routeId,
        startTime: DateTime.now(),
        isActive: true,
      );

      String tripId = await _databaseService.startTrip(newTrip);

      // Update trip with ID
      _activeTrip = Trip(
        id: tripId,
        vanId: newTrip.vanId,
        driverId: newTrip.driverId,
        routeId: newTrip.routeId,
        startTime: newTrip.startTime,
        isActive: true,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error starting trip: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // End trip
  Future<bool> endTrip() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (_activeTrip == null) {
        _errorMessage = 'No active trip found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _databaseService.endTrip(_activeTrip!.id);

      // Update local trip
      _activeTrip = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error ending trip: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update child attendance
  Future<bool> updateChildAttendance(String childId, bool isPresent) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _databaseService.updateChildAttendance(childId, isPresent);

      // Update local children list
      int index = _children.indexWhere((child) => child.id == childId);
      if (index != -1) {
        _children[index] = _children[index].copyWith(isPresent: isPresent);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating attendance: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Notification methods
  Future<void> loadNotifications() async {
    if (_currentDriver == null) return;

    try {
      _notifications =
          await _databaseService.getNotificationsByDriverId(_currentDriver!.id);
      notifyListeners();
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> createNotification(String message, String type) async {
    if (_currentDriver == null) return;

    try {
      TripNotification notification = TripNotification(
        id: '',
        driverId: _currentDriver!.id,
        message: message,
        timestamp: DateTime.now(),
        type: type,
      );

      String notificationId =
          await _databaseService.createNotification(notification);

      // Add to local list
      _notifications.insert(
          0,
          TripNotification(
            id: notificationId,
            driverId: notification.driverId,
            message: notification.message,
            timestamp: notification.timestamp,
            type: notification.type,
          ));

      notifyListeners();
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Trip proximity methods
  Future<void> updateTripProximity(bool isNear, int minutesAway) async {
    if (_activeTrip == null) return;

    try {
      await _databaseService.updateTripProximityStatus(
          _activeTrip!.id, isNear, minutesAway);

      // Update local trip
      _activeTrip = _activeTrip!.copyWith(
        isNearDestination: isNear,
        minutesAway: minutesAway,
      );

      // Create notification if newly near
      if (isNear && !_activeTrip!.isNearDestination) {
        await createNotification(
            'You are $minutesAway minutes away from your destination.',
            'proximity');
      }

      notifyListeners();
    } catch (e) {
      print('Error updating trip proximity: $e');
    }
  }
}

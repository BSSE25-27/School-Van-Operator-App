import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  Position? _currentPosition;
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  final List<Marker> _markers = [];
  List<dynamic> _children = [];
  StreamSubscription<Position>? _locationSubscription;
  Timer? _refreshTimer;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    const refreshDuration = Duration(seconds: 30);
    _refreshTimer = Timer.periodic(refreshDuration, (timer) {
      _refreshRoutes();
    });
    // Initial refresh
    _refreshRoutes();
  }

  Future<void> _startLocationUpdates() async {
    await _getCurrentLocation();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_handleNewPosition);
  }

  void _handleNewPosition(Position position) {
    setState(() {
      _currentPosition = position;
    });
    _updateCurrentLocationMarker(position);
    _sendLocationUpdate(position.latitude, position.longitude);
  }

  Future<void> _sendLocationUpdate(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vanOperatorId = prefs.getInt('VanOperatorID');

      if (vanOperatorId == null) return;

      await http.post(
        Uri.parse('$serverUrl/api/location-update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'vanOperatorId': vanOperatorId,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
    } catch (e) {
      print('Error sending location update: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _handleNewPosition(position);
      await _fetchAssignedChildren();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _updateCurrentLocationMarker(Position position) {
    _markers.removeWhere(
      (marker) => marker.markerId.value == 'current_location',
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'Van Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          anchor: const Offset(0.5, 0.5),
          rotation: position.heading,
        ),
      );
    });
  }

  Future<void> _fetchAssignedChildren() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vanOperatorId = prefs.getInt('VanOperatorID');
      if (vanOperatorId == null) return;

      final response = await http.get(
        Uri.parse('$serverUrl/api/operators/$vanOperatorId/children'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _children = data['children'] as List;
        });
        _addChildrenMarkers();
        await _generateRoutes();
      }
    } catch (e) {
      print('Error fetching children: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _lastUpdated = DateTime.now();
      });
    }
  }

  void _addChildrenMarkers() {
    for (var child in _children) {
      try {
        final lat = double.parse(child['Latitude']);
        final lng = double.parse(child['Longitude']);

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(child['ChildName']),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: child['ChildName']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          );
        });
      } catch (e) {
        print('Error parsing child location: $e');
      }
    }
  }

  Future<void> _generateRoutes() async {
    if (_currentPosition == null || _children.isEmpty) return;

    setState(() {
      _polylines.clear();
    });

    for (var child in _children) {
      try {
        final endLat = double.parse(child['Latitude']);
        final endLng = double.parse(child['Longitude']);

        final route = await _getRoute(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          LatLng(endLat, endLng),
          child['ChildName'],
        );

        if (route != null) {
          setState(() {
            _polylines.add(route);
          });
        }
      } catch (e) {
        print('Error generating route for child: $e');
      }
    }

    _zoomToFit();
  }

  Future<Polyline?> _getRoute(
    LatLng start,
    LatLng end,
    String childName,
  ) async {
    try {
      const apiKey = 'AIzaSyBWjxOJ5thrN07ci1XkZ0fZHi4mg-PIpeg';
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          return Polyline(
            polylineId: PolylineId('route_to_$childName'),
            points: _decodePolyline(points),
            color: Theme.of(context).primaryColor,
            width: 4,
            geodesic: true,
          );
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
    return null;
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<void> _zoomToFit() async {
    if (_mapController == null || _markers.isEmpty) return;

    LatLngBounds bounds = _boundsFromLatLngList(
      _markers.map((m) => m.position).toList(),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  Future<void> _refreshRoutes() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _getCurrentLocation();
    await _fetchAssignedChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Bus Routes'),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon:
                    _isRefreshing
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.refresh),
                onPressed: _refreshRoutes,
                tooltip: 'Refresh Routes',
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      _currentPosition != null
                          ? LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          )
                          : const LatLng(0.0, 0.0),
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _zoomToFit(),
                  );
                },
                polylines: _polylines,
                markers: Set<Marker>.of(_markers),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
          Positioned(
            bottom: 80,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _lastUpdated != null
                        ? 'Updated: ${_lastUpdated!.toLocal().toString().substring(11, 16)}'
                        : 'Updating...',
                    style: TextStyle(color: Colors.grey[800], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'center_location',
            onPressed: () {
              if (_currentPosition != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                  ),
                );
              }
            },
            mini: true,
            tooltip: 'Center on Van',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_fit',
            onPressed: _zoomToFit,
            mini: true,
            tooltip: 'Zoom to Fit All',
            child: const Icon(Icons.zoom_out_map),
          ),
        ],
      ),
    );
  }
}

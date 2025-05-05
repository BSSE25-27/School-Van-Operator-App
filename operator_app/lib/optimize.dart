import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  bool _isLoading = true;
  Position? _currentPosition;
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  final List<Marker> _markers = [];
  List<dynamic> _children = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Add marker for current location
      _addCurrentLocationMarker();

      // Fetch assigned children and generate routes
      await _fetchAssignedChildren();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error getting location: $e');
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition == null) return;

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  Future<void> _fetchAssignedChildren() async {
    try {
      // Retrieve VanOperatorID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final vanOperatorId = prefs.getInt('VanOperatorID');

      if (vanOperatorId == null) {
        print('VanOperatorID not found. Please log in again.');
        return;
      }

      // Replace with your API endpoint
      final apiUrl =
          'https://lightyellow-owl-629132.hostingersite.com/api/operators/$vanOperatorId/children';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _children = data['children'] as List;
        });

        // Add markers for children locations
        _addChildrenMarkers();

        // Generate routes
        await _generateRoutes();
      } else {
        print('Failed to fetch children: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching children: $e');
    } finally {
      setState(() {
        _isLoading = false;
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

    // Clear existing polylines
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

    // Zoom to fit all markers and routes
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
            color: Colors.blue,
            width: 5,
            geodesic: true,
            zIndex: 1,
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

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);
    _mapController?.animateCamera(cameraUpdate);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School Bus Routes'), centerTitle: true),
      body:
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
                  // Zoom to fit all markers after map is created
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _zoomToFit(),
                  );
                },
                polylines: _polylines,
                markers: Set<Marker>.of(_markers),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshRoutes,
        tooltip: 'Refresh Routes',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> _refreshRoutes() async {
    setState(() {
      _isLoading = true;
      _polylines.clear();
      _markers.clear();
    });

    await _getCurrentLocation();
    await _fetchAssignedChildren();
  }
}

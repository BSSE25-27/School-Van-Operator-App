import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({Key? key}) : super(key: key);

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  bool _isLoading = true;
  List<RouteModel> _routes = [];
  Position? _currentPosition;
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  List<LatLng> _childrenLocations = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
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
        _startController.text = '${position.latitude}, ${position.longitude}';
      });

      // Fetch assigned children and generate routes
      await _fetchAssignedChildren();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error getting location: $e');
    }
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
        final children = data['children'] as List;

        setState(() {
          _childrenLocations =
              children
                  .map(
                    (child) => LatLng(
                      double.parse(child['Latitude']),
                      double.parse(child['Longitude']),
                    ),
                  )
                  .toList();
        });

        // Generate routes
        await _generateRoutes();
      } else {
        print('Failed to fetch children: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching children: $e');
    }
  }

  Future<void> _generateRoutes() async {
    if (_currentPosition == null || _childrenLocations.isEmpty) return;

    for (LatLng childLocation in _childrenLocations) {
      final route = await _getRoute(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        childLocation,
      );

      if (route != null) {
        setState(() {
          _polylines.add(route);
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<Polyline?> _getRoute(LatLng start, LatLng end) async {
    try {
      // Use the same API key as in the AndroidManifest.xml
      const apiKey = 'AIzaSyBWjxOJ5thrN07ci1XkZ0fZHi4mg-PIpeg';
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

      print('Requesting route: $url'); // Log the request URL

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response: $data'); // Log the response

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];

          return Polyline(
            polylineId: PolylineId(end.toString()),
            points: _decodePolyline(points),
            color: Colors.blue,
            width: 5,
          );
        } else {
          print('No routes found in the response.');
        }
      } else {
        print('Failed to fetch route: ${response.statusCode}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Optimization'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition:
                        _currentPosition != null
                            ? CameraPosition(
                              target: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              zoom: 14,
                            )
                            : const CameraPosition(
                              target: LatLng(
                                0.0,
                                0.0,
                              ), // Default position if location is not available
                              zoom: 2,
                            ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    polylines: _polylines,
                    markers:
                        _childrenLocations
                            .map(
                              (location) => Marker(
                                markerId: MarkerId(location.toString()),
                                position: location,
                              ),
                            )
                            .toSet(),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: _buildSearchInputs(),
                  ),
                ],
              ),
    );
  }

  Widget _buildSearchInputs() {
    return Column(
      children: [
        TextField(
          controller: _startController,
          decoration: InputDecoration(
            hintText: 'From',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _endController,
          decoration: InputDecoration(
            hintText: 'To',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class RouteModel {
  final String id;
  final String name;
  final String startLocation;
  final String endLocation;
  final int estimatedTimeMinutes;
  final double distanceKm;
  final String? comingFrom;

  RouteModel({
    required this.id,
    required this.name,
    required this.startLocation,
    required this.endLocation,
    required this.estimatedTimeMinutes,
    required this.distanceKm,
    this.comingFrom,
  });
}

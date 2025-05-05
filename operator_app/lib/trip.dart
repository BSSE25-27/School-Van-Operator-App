import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class AppProvider {
  get assignedVan => null;

  void updateTripProximity(bool _, int simulatedMinutesAway) {
    debugPrint("Proximity update: $simulatedMinutesAway minutes away");
  }

  void updateTripTrafficAlert(bool _) {
    debugPrint("Traffic alert triggered");
  }

  void updateTripDestinationStatus(bool _) {
    debugPrint("Destination reached");
  }

  void endTrip() {
    debugPrint("Trip ended");
  }
}

class _TripPageState extends State<TripPage> {
  final AppProvider appProvider = AppProvider();
  Timer? _locationTimer;
  int _simulatedMinutesAway = 20;
  bool _hasReachedDestination = false;
  bool _hasTrafficAlert = false;

  final Completer<GoogleMapController> _mapController = Completer();
  static const LatLng _initialPosition = LatLng(0.3476, 32.5825); // Kampala

  @override
  void initState() {
    super.initState();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateLocation();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _updateLocation() {
    if (_simulatedMinutesAway > 0) {
      setState(() {
        _simulatedMinutesAway -= 1;
      });

      appProvider.updateTripProximity(true, _simulatedMinutesAway);

      if (!_hasTrafficAlert &&
          _simulatedMinutesAway > 10 &&
          _simulatedMinutesAway < 15 &&
          DateTime.now().second % 5 == 0) {
        setState(() {
          _hasTrafficAlert = true;
        });
        appProvider.updateTripTrafficAlert(true);
      }

      if (_simulatedMinutesAway == 0 && !_hasReachedDestination) {
        setState(() {
          _hasReachedDestination = true;
        });
        appProvider.updateTripDestinationStatus(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            markers: {
              Marker(
                markerId: const MarkerId("bus"),
                position: _initialPosition,
                infoWindow: const InfoWindow(title: "Bus Location"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
            },
          ),

          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Column(
              children: [
                if (_hasReachedDestination)
                  _buildAlertBanner(
                    'You have reached your destination.',
                    Colors.green,
                  ),
                if (!_hasReachedDestination)
                  _buildAlertBanner(
                    'ALERT!: Bus arrives in $_simulatedMinutesAway minutes',
                    const Color(0xFF9D7BB0),
                  ),
                if (_hasTrafficAlert) _buildTrafficAlert(),
              ],
            ),
          ),

          _buildTripInfoPanel(),

          Positioned(top: 40, left: 16, child: _buildBackButton()),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(String message, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficAlert() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.traffic, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Your selected route looks busy, you may choose other available routes.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTripDetail(Icons.access_time, 'ETA', 'Arriving at 14:30'),
            const SizedBox(height: 16),
            _buildTripDetail(Icons.timer, 'Trip time', 'Approximately 2 hours'),
            const SizedBox(height: 16),
            _buildTripDetail(
              Icons.directions_bus,
              'Number plate',
              appProvider.assignedVan?.numberPlate ?? 'UBA 234S',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  appProvider.endTrip();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D7BB0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('End Trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetail(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9D7BB0)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }
}

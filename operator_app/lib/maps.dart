import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:operator_app/draw.dart';

class VanOperatorHomeScreen extends StatefulWidget {
  const VanOperatorHomeScreen({super.key});

  @override
  _VanOperatorHomeScreenState createState() => _VanOperatorHomeScreenState();
}

class _VanOperatorHomeScreenState extends State<VanOperatorHomeScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(0.3818, 32.6186); // Kira

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: VanOperatorDrawer(),
      appBar: AppBar(
        title: const Text("Van Operator"),
        backgroundColor: Colors.deepPurple[100],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.deepPurple[100]),
                        SizedBox(width: 10),
                        Expanded(child: Text("CJJR+XG Kira Town, Uganda")),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children:  [
                        Icon(Icons.search, color: Colors.deepPurple[100]),
                        SizedBox(width: 10),
                        Expanded(child: Text("Where to?")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

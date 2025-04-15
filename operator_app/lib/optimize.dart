import 'package:flutter/material.dart';
import 'trip.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({Key? key}) : super(key: key);

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final TextEditingController _startController = TextEditingController(
    text: 'Kiwatule',
  );
  final TextEditingController _endController = TextEditingController(
    text: 'Namugongo',
  );

  bool _isLoading = true;
  List<RouteModel> _routes = [];

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Replace this with actual API call logic
    setState(() {
      _routes = [
        RouteModel(
          id: 'route1',
          name: 'Route 01',
          startLocation: 'Kiwatule',
          endLocation: 'Namugongo',
          estimatedTimeMinutes: 21,
          distanceKm: 2.0,
          comingFrom: 'Ntinda',
        ),
        RouteModel(
          id: 'route2',
          name: 'Route 02',
          startLocation: 'Kiwatule',
          endLocation: 'Namugongo',
          estimatedTimeMinutes: 25,
          distanceKm: 3.5,
          comingFrom: 'Bukoto',
        ),
        RouteModel(
          id: 'route3',
          name: 'Route 03',
          startLocation: 'Kiwatule',
          endLocation: 'Namugongo',
          estimatedTimeMinutes: 30,
          distanceKm: 5.0,
          comingFrom: 'Bugolobi',
        ),
        RouteModel(
          id: 'route4',
          name: 'Route 04',
          startLocation: 'Kiwatule',
          endLocation: 'Namugongo',
          estimatedTimeMinutes: 45,
          distanceKm: 7.0,
          comingFrom: 'Kisaasi',
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Select Route',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchInputs(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Routes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                              itemCount: _routes.length,
                              itemBuilder: (context, index) {
                                final route = _routes[index];
                                return _buildRouteItem(
                                  route.name,
                                  '${route.startLocation} to ${route.endLocation}',
                                  route.estimatedTimeMinutes,
                                  route.distanceKm,
                                  route.comingFrom ?? '',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const TripPage(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInputs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _startController,
            decoration: InputDecoration(
              hintText: 'From',
              prefixIcon: const Icon(
                Icons.location_on,
                color: Color(0xFF9D7BB0),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _endController,
            decoration: InputDecoration(
              hintText: 'To',
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF9D7BB0),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(
    String routeName,
    String routeDescription,
    int minutes,
    double distance,
    String comingFrom,
    VoidCallback onSelect,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Color(0xFF9D7BB0)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routeName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    routeDescription,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$minutes',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9D7BB0),
                      ),
                    ),
                    Text(
                      'minutes away',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.wifi, color: Color(0xFF9D7BB0)),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$distance Km Away From You',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Coming From $comingFrom',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9D7BB0),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Select Route'),
            ),
          ),
        ],
      ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'trip_page.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({Key? key}) : super(key: key);

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final TextEditingController _startController = TextEditingController(text: 'Kiwatule');
  final TextEditingController _endController = TextEditingController(text: 'Namugongo');
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoutes();
    });
  }
  
  Future<void> _loadRoutes() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.getRoutes('Mirpur-12', 'Dhanmondi');
  }
  
  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    
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
          // Search inputs
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _startController,
                  decoration: InputDecoration(
                    hintText: 'From',
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFF9D7BB0)),
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
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF9D7BB0)),
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
          ),
          
          // Recommended routes
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Routes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Routes list
                  Expanded(
                    child: appProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: appProvider.routes.isEmpty ? 4 : appProvider.routes.length,
                            itemBuilder: (context, index) {
                              // Use sample data if routes are empty
                              final routeName = appProvider.routes.isEmpty 
                                  ? 'Route ${(index + 1).toString().padLeft(2, '0')}' 
                                  : appProvider.routes[index].name;
                              
                              final startLocation = appProvider.routes.isEmpty 
                                  ? 'Mirpur-12' 
                                  : appProvider.routes[index].startLocation;
                              
                              final endLocation = appProvider.routes.isEmpty 
                                  ? 'Dhanmondi' 
                                  : appProvider.routes[index].endLocation;
                              
                              final minutes = appProvider.routes.isEmpty 
                                  ? [21, 25, 30, 45][index] 
                                  : appProvider.routes[index].estimatedTimeMinutes;
                              
                              final distance = appProvider.routes.isEmpty 
                                  ? [2.0, 3.5, 5.0, 7.0][index] 
                                  : appProvider.routes[index].distanceKm;
                              
                              final comingFrom = appProvider.routes.isEmpty 
                                  ? ['Mirpur-02', 'Mirpur-01', 'Mirpur-02', 'Mirpur-03'][index] 
                                  : appProvider.routes[index].comingFrom ?? '';
                              
                              return _buildRouteItem(
                                routeName,
                                '$startLocation to $endLocation',
                                minutes,
                                distance,
                                comingFrom,
                                () {
                                  // Start trip with selected route
                                  appProvider.startTrip(appProvider.routes.isEmpty 
                                      ? 'route${index + 1}' 
                                      : appProvider.routes[index].id);
                                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TripPage()),
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
          // Route name and description
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Color(0xFF9D7BB0)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    routeDescription,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Time and distance
          Row(
            children: [
              // Time
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Signal strength
              const Icon(
                Icons.wifi,
                color: Color(0xFF9D7BB0),
              ),
              
              // Distance and origin
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Select button
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


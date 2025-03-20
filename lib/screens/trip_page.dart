import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class TripPage extends StatefulWidget {
  const TripPage({Key? key}) : super(key: key);

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  Timer? _locationTimer;
  int _simulatedMinutesAway = 20;
  bool _hasReachedDestination = false;
  bool _hasTrafficAlert = false;
  
  @override
  void initState() {
    super.initState();
    // Simulate location updates
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
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Simulate getting closer to destination
    if (_simulatedMinutesAway > 0) {
      setState(() {
        _simulatedMinutesAway -= 1;
      });
      
      // Update trip proximity status
      appProvider.updateTripProximity(true, _simulatedMinutesAway);
      
      // Randomly simulate traffic alert (20% chance)
      if (!_hasTrafficAlert && _simulatedMinutesAway > 10 && _simulatedMinutesAway < 15 && DateTime.now().second % 5 == 0) {
        setState(() {
          _hasTrafficAlert = true;
        });
        appProvider.updateTripTrafficAlert(true);
      }
      
      // When we reach destination
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
    final appProvider = Provider.of<AppProvider>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Map
          Image.asset(
            'assets/map.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.map,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
          
          // Alert banner
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Destination reached alert
                if (_hasReachedDestination)
                  _buildAlertBanner(
                    'You have reached your destination.',
                    Colors.green,
                  ),
                
                // Minutes away alert
                if (!_hasReachedDestination)
                  _buildAlertBanner(
                    'ALERT!: Bus arrives in $_simulatedMinutesAway minutes',
                    const Color(0xFF9D7BB0),
                  ),
                
                // Traffic alert
                if (_hasTrafficAlert)
                  Container(
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
                          child: const Icon(
                            Icons.traffic,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Your selected route looks busy, you may choose other available routes.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Trip info panel
          Positioned(
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
                  // ETA
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9D7BB0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          color: Color(0xFF9D7BB0),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ETA',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'You are likely to arrive to the guardian at 14:30',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Trip time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9D7BB0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.timer,
                          color: Color(0xFF9D7BB0),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trip time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Approximately 2 hours',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Number plate
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9D7BB0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Color(0xFF9D7BB0),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Number plate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              appProvider.assignedVan?.numberPlate ?? 'UBA 234S',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // End trip button
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
          ),
          
          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: Container(
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
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
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
            child: Icon(
              Icons.notifications,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


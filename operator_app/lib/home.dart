import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'attend.dart';
import 'profile.dart';
import 'notification.dart';
import 'draw.dart';
import 'maps.dart';
import 'config.dart';
import 'optimize.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? operatorData;
  bool isLoading = true;
  bool isRefreshing = false;
  String errorMessage = '';
  int? vanOperatorId;
  Timer? _refreshTimer;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadVanOperatorId();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    const refreshDuration = Duration(seconds: 30);
    _refreshTimer = Timer.periodic(refreshDuration, (timer) {
      _fetchOperatorData();
    });
  }

  Future<void> _loadVanOperatorId() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      vanOperatorId = prefs.getInt('VanOperatorID');

      if (vanOperatorId == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'VanOperatorID not found. Please log in again.';
        });
        return;
      }

      await _fetchOperatorData();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading VanOperatorID: $e';
      });
    }
  }

  Future<void> _fetchOperatorData() async {
    if (isRefreshing) return;

    setState(() {
      isRefreshing = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/operators/$vanOperatorId/children'),
      );

      if (response.statusCode == 200) {
        setState(() {
          operatorData = json.decode(response.body);
          isLoading = false;
          _lastUpdated = DateTime.now();
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFF6A3B9C);
    final backgroundColor = const Color(0xFF9D7BB0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon:
                isRefreshing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchOperatorData,
          ),
        ],
      ),
      drawer: const VanOperatorDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child:
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(),
                          heightFactor: 5,
                        )
                        : errorMessage.isNotEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Center(
                              child: Text(
                                'Welcome!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Welcome Card
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Image.asset(
                                      "assets/icons/van.png",
                                      height: 100,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "Welcome, ${operatorData!['VanOperatorName']}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Vehicle: ${operatorData!['VanNumberPlate']}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Total Children: ${operatorData!['totalChildren']}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Assigned Children Info
                            _buildInfoCard(
                              'ASSIGNED CHILDREN: ${operatorData!['totalChildren']}',
                              Icons.people,
                            ),
                            const SizedBox(height: 16),

                            _buildInfoCard(
                              'VAN NUMBER-PLATE: ${operatorData!['VanNumberPlate']}',
                              Icons.directions_bus,
                            ),
                            const SizedBox(height: 16),

                            _buildInfoCard(
                              'ROUTES: ${operatorData!['assignedRoute'] ?? 'N/A'}',
                              Icons.map,
                            ),
                            const SizedBox(height: 40),

                            // Start Trip Button
                            _buildActionButton(
                              'Start Trip',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RoutesPage(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Attendance Button
                            _buildActionButton(
                              'Attendance',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const AttendanceScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
              ),
            ),
            if (_lastUpdated != null)
              Positioned(
                bottom: 70,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                      Icon(Icons.access_time, size: 16, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Updated: ${_lastUpdated!.toLocal().toString().substring(11, 16)}',
                        style: TextStyle(color: Colors.grey[800], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A3B9C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 3,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

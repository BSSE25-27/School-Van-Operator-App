import 'package:flutter/material.dart';
import 'package:operator_app/login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the globally stored operator data
    final operatorData = loggedInOperator;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SafeArea(
        child:
            operatorData == null
                ? const Center(
                  child: Text(
                    "No operator data available. Please log in.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage(
                                "assets/icons/van.png",
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              operatorData['VanOperatorName'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              operatorData['PhoneNumber'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Details Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.email,
                                  color: Colors.deepPurple,
                                ),
                                title: const Text("Email"),
                                subtitle: Text(
                                  operatorData['Email'] ?? 'Unknown',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.phone,
                                  color: Colors.deepPurple,
                                ),
                                title: const Text("Phone"),
                                subtitle: Text(
                                  operatorData['PhoneNumber'] ?? 'Unknown',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: Colors.deepPurple,
                                ),
                                title: const Text("Operator ID"),
                                subtitle: Text(
                                  operatorData['VanOperatorID'].toString(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                ); // Navigate back to login
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text("Logout"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

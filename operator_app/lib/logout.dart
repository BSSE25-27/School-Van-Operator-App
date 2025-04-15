import 'package:flutter/material.dart';
import 'package:operator_app/login.dart'; // Make sure to import your login screen

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Automatically show logout confirmation when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLogoutConfirmation(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logout"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: CircularProgressIndicator(), // Show loading while processing
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _performLogout(context); // Proceed with logout
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    // TODO: Add your actual logout logic here (clear tokens, user data, etc.)

    // Navigate to login screen and clear navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}

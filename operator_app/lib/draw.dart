import 'package:flutter/material.dart';
import 'package:operator_app/maps.dart';

class VanOperatorDrawer extends StatelessWidget {
  const VanOperatorDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("Mumbere Joshua"),
              accountEmail: const Text("762729599"),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 42),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            drawerItem(Icons.person, "My Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }),
            drawerItem(Icons.car_rental, "Navigation", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VanOperatorHomeScreen(),
                ),
              );
            }),
            drawerItem(Icons.qr_code_scanner, "QR Code Scanner", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRCodeScreen()),
              );
            }),
            drawerItem(Icons.alt_route, "Route Optimization", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OptimizationScreen(),
                ),
              );
            }),
            drawerItem(Icons.receipt_long, "Attendance", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceScreen(),
                ),
              );
            }),
            drawerItem(Icons.verified_user, "Terms and Conditions", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsScreen()),
              );
            }),
            drawerItem(Icons.notifications, "Notifications", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            }),
            drawerItem(Icons.help_outline, "Help", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            }),
            drawerItem(Icons.logout, "LogOut", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogoutScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  ListTile drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple[200]),
      title: Text(title),
      onTap: onTap,
    );
  }
}

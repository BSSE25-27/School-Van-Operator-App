import 'package:flutter/material.dart';

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
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
            ),
            drawerItem(Icons.person, "My Profile"),
            drawerItem(Icons.car_rental, "Trip History"),
            drawerItem(Icons.receipt_long, "Transaction History"),
            drawerItem(Icons.verified_user, "Terms and Conditions"),
            drawerItem(Icons.notifications, "Notifications"),
            drawerItem(Icons.help_outline, "Help"),
          ],
        ),
      ),
    );
  }

  ListTile drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple[200]),
      title: Text(title),
      onTap: () {
        // Navigate or perform action
      },
    );
  }
}

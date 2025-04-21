import 'package:flutter/material.dart';
import 'package:operator_app/maps.dart';
import 'package:operator_app/profile.dart';
import 'package:operator_app/qr_code.dart';
import 'package:operator_app/optimize.dart';
import 'package:operator_app/attend.dart';
import 'package:operator_app/terms.dart';
import 'package:operator_app/notification.dart';
import 'package:operator_app/help.dart';
import 'package:operator_app/logout.dart';
import 'package:operator_app/login.dart'; // Import for loggedInOperator

class VanOperatorDrawer extends StatelessWidget {
  const VanOperatorDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the globally stored operator data
    final operatorData = loggedInOperator;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade400,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operatorData?['VanOperatorName'] ?? 'Unknown Operator',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        operatorData?['PhoneNumber'] ?? 'Unknown Phone',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSectionHeader("OPERATIONS"),
                  _buildDrawerItem(
                    icon: Icons.car_rental,
                    title: "Navigation",
                    onTap:
                        () =>
                            _navigateTo(context, const VanOperatorHomeScreen()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.qr_code_scanner,
                    title: "QR Code Scanner",
                    onTap:
                        () => _navigateTo(
                          context,
                          const ParentQRScannerScreen(childId: '1'),
                        ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.alt_route,
                    title: "Route Optimization",
                    onTap: () => _navigateTo(context, const RoutesPage()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long,
                    title: "Attendance",
                    onTap: () => _navigateTo(context, const AttendanceScreen()),
                  ),

                  _buildSectionHeader("ACCOUNT"),
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: "My Profile",
                    onTap: () => _navigateTo(context, const ProfileScreen()),
                  ),

                  _buildSectionHeader("SUPPORT"),
                  _buildDrawerItem(
                    icon: Icons.notifications,
                    title: "Notifications",
                    badgeCount: 3,
                    onTap:
                        () => _navigateTo(context, const NotificationScreen()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: "Help",
                    onTap: () => _navigateTo(context, const HelpScreen()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.verified_user,
                    title: "Terms and Conditions",
                    onTap: () => _navigateTo(context, const TermsScreen()),
                  ),

                  const Divider(height: 20, thickness: 1),

                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: "Log Out",
                    color: Colors.red.shade400,
                    onTap: () => _navigateTo(context, const LogoutScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.deepPurple.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? color,
    int? badgeCount,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? Colors.deepPurple).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? Colors.deepPurple.shade600, size: 22),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey.shade800,
            ),
          ),
          if (badgeCount != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer first
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }
}

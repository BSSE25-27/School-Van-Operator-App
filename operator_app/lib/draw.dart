import 'package:flutter/material.dart';
import 'package:operator_app/maps.dart';
import 'package:operator_app/profile.dart';
import 'package:operator_app/qr.dart';
import 'package:operator_app/optimize.dart';
import 'package:operator_app/attend.dart';
import 'package:operator_app/terms.dart';
import 'package:operator_app/notification.dart';
import 'package:operator_app/help.dart';
import 'package:operator_app/logout.dart';
import 'package:operator_app/login.dart';

class VanOperatorDrawer extends StatelessWidget {
  const VanOperatorDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final operatorData = loggedInOperator;
    final theme = Theme.of(context);
    final primaryColor = Colors.deepPurple;
    final accentColor = Colors.deepPurpleAccent;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Enhanced Header with Material Design 3 styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor.shade100, accentColor.shade400],
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 36, color: primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          operatorData?['VanOperatorName'] ?? 'Operator',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          operatorData?['PhoneNumber'] ?? 'No phone number',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        // const SizedBox(height: 4),
                        // Text(
                        //   operatorData?['VanNumberPlate'] ?? 'No vehicle',
                        //   style: TextStyle(
                        //     color: Colors.white.withOpacity(0.9),
                        //     fontSize: 14,
                        //     fontFamily: 'monospace',
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items with smooth scrolling
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(25),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 8),
                    _buildSectionHeader("OPERATIONS", primaryColor),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.directions_car_filled,
                      title: "Navigation",
                      onTap: () => _navigateTo(context, const RoutesPage()),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.qr_code_scanner_rounded,
                      title: "QR Scanner",
                      onTap: () => _navigateTo(context, const ParentQR()),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.alt_route_rounded,
                      title: "Route Optimization",
                      onTap: () => _navigateTo(context, const RoutesPage()),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.assignment_turned_in_rounded,
                      title: "Attendance",
                      onTap:
                          () => _navigateTo(context, const AttendanceScreen()),
                    ),

                    _buildSectionHeader("ACCOUNT", primaryColor),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.account_circle_rounded,
                      title: "My Profile",
                      onTap: () => _navigateTo(context, const ProfileScreen()),
                    ),

                    _buildSectionHeader("SUPPORT", primaryColor),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.notifications_active_rounded,
                      title: "Notifications",
                      badgeCount: 3,
                      onTap:
                          () =>
                              _navigateTo(context, const NotificationScreen()),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.help_center_rounded,
                      title: "Help Center",
                      onTap: () => _navigateTo(context, const HelpScreen()),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.privacy_tip_rounded,
                      title: "Terms & Privacy",
                      onTap: () => _navigateTo(context, const TermsScreen()),
                    ),

                    const Divider(
                      height: 24,
                      thickness: 1,
                      indent: 24,
                      endIndent: 24,
                    ),

                    _buildDrawerItem(
                      context: context,
                      icon: Icons.logout_rounded,
                      title: "Sign Out",
                      color: Colors.red.shade600,
                      onTap: () => _navigateTo(context, const LogoutScreen()),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
      child: Text(
        title,
        style: TextStyle(
          color: primaryColor.withOpacity(0.8),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? color,
    int? badgeCount,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white70 : Colors.grey.shade800;
    final hoverColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            hoverColor: hoverColor,
            splashColor:
                color?.withOpacity(0.2) ?? theme.primaryColor.withOpacity(0.2),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (color ?? theme.primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color ?? theme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: color ?? defaultColor,
                      ),
                    ),
                  ),
                  if (badgeCount != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.circular(12),
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
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

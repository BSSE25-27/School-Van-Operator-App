import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Need help operating the app?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Operator Guide:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.directions_bus, color: Colors.deepPurple),
              title: const Text("How to start a trip"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Starting a Trip"),
                    content: const Text(
                      "Go to the 'Trips' tab, select your assigned trip, and press 'Start Trip'. Make sure GPS is enabled.",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.deepPurple),
              title: const Text("Marking student attendance"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Marking Attendance"),
                    content: const Text(
                      "When students board or leave the van, mark their status in the 'Attendance' section to keep parents updated.",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Got it"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem, color: Colors.deepPurple),
              title: const Text("Reporting a vehicle issue"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Reporting an Issue"),
                    content: const Text(
                      "If you experience any issues with the van, go to the 'Report Issue' section and fill in the problem details.",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Understood"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.support_agent),
                label: const Text("Contact Admin"),
                onPressed: () {
                  // Replace this with your actual support logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Contacting school admin...")),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

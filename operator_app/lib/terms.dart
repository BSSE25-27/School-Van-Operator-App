import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final terms = [
      {
        'title': '1. Acceptance of Terms',
        'content':
            'By using this application, you agree to comply with these terms and conditions.',
        'icon': Icons.check_circle_outline,
      },
      {
        'title': '2. Changes to Terms',
        'content':
            'We reserve the right to modify these terms at any time. Continued use indicates your acceptance.',
        'icon': Icons.sync_alt,
      },
      {
        'title': '3. User Responsibilities',
        'content':
            'You are responsible for keeping your account information secure and for activities under your account.',
        'icon': Icons.lock_outline,
      },
      {
        'title': '4. Limitation of Liability',
        'content':
            'We are not liable for damages resulting from the use of this application.',
        'icon': Icons.warning_amber_outlined,
      },
      {
        'title': '5. Governing Law',
        'content': 'These terms follow the laws of your place of residence.',
        'icon': Icons.gavel_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms and Conditions"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Please read the terms carefully before using the app.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: terms.length,
                itemBuilder: (context, index) {
                  final term = terms[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        term['icon'] as IconData,
                        color: Colors.deepPurple,
                      ),
                      title: Text(
                        term['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          term['content'] as String,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Or proceed to next screen
              },
              icon: const Icon(Icons.check),
              label: const Text("I Understand"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

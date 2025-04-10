import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms and Conditions"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Terms and Conditions",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "1. Acceptance of Terms\n"
                "By using this application, you agree to comply with these terms and conditions.\n\n"
                "2. Changes to Terms\n"
                "We reserve the right to modify these terms at any time. Your continued use of the app after changes indicates your acceptance of the new terms.\n\n"
                "3. User Responsibilities\n"
                "You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.\n\n"
                "4. Limitation of Liability\n"
                "We are not liable for any damages arising from your use of this application.\n\n"
                "5. Governing Law\n"
                "These terms are governed by the laws of the jurisdiction in which you reside.\n",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class OptimizationScreen extends StatelessWidget {
  const OptimizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Optimization"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(child: const Text("Route Optimization Screen")),
    );
  }
}

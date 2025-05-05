import 'package:flutter/material.dart';
import 'package:operator_app/draw.dart';
import 'package:operator_app/qr_code.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<Map<String, dynamic>> children = [
    {"id": "CH001", "eta": "8:15 AM", "isPresent": true},
    {"id": "CH002", "eta": "8:18 AM", "isPresent": false},
    {"id": "CH003", "eta": "8:20 AM", "isPresent": true},
  ];

  @override
  Widget build(BuildContext context) {
    int checkedCount = children.where((child) => child["isPresent"]).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Colors.deepPurple[100],
      ),
      drawer: const VanOperatorDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "School Van Attendance",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.deepPurple[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$checkedCount of ${children.length}\nChecked In",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const Icon(Icons.check_circle, size: 40, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const ParentQRScannerScreen(childId: '1'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Scan QR Code"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10), // Removed const here
                    Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FlexColumnWidth(),
                        1: FlexColumnWidth(),
                        2: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: Colors.grey),
                          children: [
                            const TableCell(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Child ID",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const TableCell(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "ETA",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const TableCell(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Scanned",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...children.map((child) {
                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: Text(child["id"])),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: Text(child["eta"])),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Icon(
                                      child["isPresent"]
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color:
                                          child["isPresent"]
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

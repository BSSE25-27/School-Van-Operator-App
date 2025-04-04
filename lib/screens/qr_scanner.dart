import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = "Scan a QR code";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Scanner")),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
              ),
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedData,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (!mounted) return;

      String rawData = scanData.code ?? "No Data";
      print("🔹 Scanned Data: $rawData");

      setState(() {
        scannedData = rawData; // Show scanned text immediately
      });

      try {
        // Attempt to parse as JSON
        final Map<String, dynamic> jsonData = json.decode(rawData);

        // If it's valid JSON, format the output
        if (jsonData.containsKey('parent_name') &&
            jsonData.containsKey('child_name') &&
            jsonData.containsKey('child_class')) {
          setState(() {
            scannedData = """
Parent Name: ${jsonData['parent_name']}
Parent Contact: ${jsonData['parent_contact']}
Child ID: ${jsonData['child_id']}
Child Name: ${jsonData['child_name']}
Child Class: ${jsonData['child_class']}
""";
          });
        }
      } catch (e) {
        print("Error parsing JSON: $e");
        // If it’s not JSON, just show the raw scanned text
      }
    });
  }
}

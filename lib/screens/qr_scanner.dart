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
      appBar: AppBar(),
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
            child: Center(child: Text(scannedData)),
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

      try {
        // Attempt to parse JSON
        final Map<String, dynamic> jsonData = json.decode(rawData);

        if (jsonData.containsKey('id') && jsonData['id'] != null) {
          // Send data to the api to confirm child's attendance.
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      } catch (e) {
        print("Error parsing JSON: $e");
      }

      setState(() {
        scannedData = rawData;
      });
    });
  }
}

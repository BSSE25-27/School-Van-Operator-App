import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? scannedData; // Variable to store scanned QR code data

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    // Handle the barcode data here
    final barcode = barcodeCapture.barcodes.first.rawValue;
    if (barcode != null) {
      setState(() {
        scannedData = barcode; // Update the scanned data
      });
      debugPrint('Barcode found: $barcode');
    } else {
      debugPrint('No barcode detected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(flex: 4, child: MobileScanner(onDetect: _handleBarcode)),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedData ?? "Scan a QR Code",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

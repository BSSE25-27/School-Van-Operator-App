import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ParentQR extends StatefulWidget {
  const ParentQR({super.key, required this.onScanComplete});

  final Function(String childId) onScanComplete;

  @override
  State<ParentQR> createState() => _ParentQRState();
}

class _ParentQRState extends State<ParentQR> {
  String result = '';
  bool? isVerified;

  Future<void> _scanQR() async {
    try {
      final res = await SimpleBarcodeScanner.scanBarcode(
        context,
        barcodeAppBar: const BarcodeAppBar(
          appBarTitle: 'Test',
          centerTitle: false,
          enableBackButton: true,
          backButtonIcon: Icon(Icons.arrow_back_ios),
        ),
        isShowFlashIcon: true,
        delayMillis: 500,
        cameraFace: CameraFace.back,
        scanFormat: ScanFormat.ONLY_QR_CODE,
      );

      if (res == null) {
        throw Exception('Scan cancelled or failed');
      }

      String scannedChildId;

      if (res.trim().startsWith('{') && res.trim().endsWith('}')) {
        final qrData = json.decode(res) as Map<String, dynamic>;
        scannedChildId = qrData['child_id'].toString();
      } else {
        scannedChildId = res;
      }

      final prefs = await SharedPreferences.getInstance();
      final childIds = prefs.getStringList('child_ids') ?? [];
      final isChildIdValid = childIds.contains(scannedChildId);

      setState(() {
        result = 'Scanned Child ID: $scannedChildId';
        isVerified = isChildIdValid;
      });

      if (isChildIdValid) {
        widget.onScanComplete(scannedChildId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isChildIdValid
                ? 'Verification successful!'
                : 'Verification failed. Child ID $scannedChildId not found in assigned list.',
          ),
          backgroundColor: isChildIdValid ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        result = 'Error: ${e.toString()}';
        isVerified = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _scanQR,
              child: const Text('SCAN QRCode'),
            ),
            const SizedBox(height: 20),
            Text(
              'Status: ${isVerified == null ? 'Not scanned' : (isVerified! ? '✅ Verified' : '❌ Not Verified')}',
              style: TextStyle(
                color:
                    isVerified == null
                        ? Colors.grey
                        : (isVerified! ? Colors.green : Colors.red),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Text('Result:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(result),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:operator_app/login.dart'; // Import for loggedInOperator

class ParentQRScannerScreen extends StatefulWidget {
  final String childId; // The child being picked up

  const ParentQRScannerScreen({super.key, required this.childId});

  @override
  State<ParentQRScannerScreen> createState() => _ParentQRScannerScreenState();
}

class _ParentQRScannerScreenState extends State<ParentQRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;
  bool isProcessing = false;
  String? verificationStatus;
  Map<String, dynamic>? verificationResult;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (isProcessing) return;

    final barcode = barcodeCapture.barcodes.first;
    if (barcode.rawValue == null) {
      _showError('No QR code detected');
      return;
    }

    setState(() {
      isProcessing = true;
      verificationStatus = 'Verifying parent...';
    });

    try {
      // Parse the JSON data from QR code
      final qrData = jsonDecode(barcode.rawValue!);
      final parentId = qrData['parent_id']?.toString();
      final childId = qrData['child_id']?.toString();

      if (parentId == null || childId == null) {
        throw const FormatException(
          'Invalid QR format - missing parent_id or child_id',
        );
      }

      // Get the VanOperatorID from the logged-in operator
      final vanOperatorId = loggedInOperator?['VanOperatorID']?.toString();
      if (vanOperatorId == null) {
        throw Exception('VanOperatorID is not available. Please log in again.');
      }

      // Call verification API
      final result = await _verifyPickup(
        parentId: parentId,
        childId: childId,
        vanOperatorId: vanOperatorId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          verificationStatus = 'Verification successful';
          verificationResult = {
            'parent_name': qrData['parent_name'],
            'child_name': result['child_name'],
          };
        });

        // Show success dialog
        _showVerificationDialog(
          context,
          true,
          qrData['parent_name'],
          result['child_name'],
        );
      } else {
        _showError(result['message'] ?? 'Verification failed');
        _resetScanner();
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
      _resetScanner();
    }
  }

  Future<Map<String, dynamic>> _verifyPickup({
    required String parentId,
    required String childId,
    required String vanOperatorId,
  }) async {
    const apiUrl =
        'https://lightyellow-owl-629132.hostingersite.com/api/verify-pickup';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'parent_id': parentId, // Match Laravel's validation key
        'child_id': childId, // Match Laravel's validation key
        'van_operator_id': vanOperatorId, // Match Laravel's validation key
        'verification_time': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API request failed with status ${response.statusCode}');
    }
  }

  void _showVerificationDialog(
    BuildContext context,
    bool isSuccess,
    String parentName,
    String childName,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              isSuccess ? 'Verification Successful' : 'Verification Failed',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSuccess) ...{
                  Text(
                    'Parent: $parentName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Child: $childName'),
                  const SizedBox(height: 16),
                  const Text('You may now release the child to the parent.'),
                } else
                  const Text(
                    'The QR code is invalid or the parent is not authorized to pick up this child.',
                  ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetScanner();
                },
                child: const Text('OK'),
              ),
              if (isSuccess)
                ElevatedButton(
                  onPressed: () {
                    // Log the successful handover
                    _logHandover(
                      parentId: verificationResult!['parent_id'],
                      childId: widget.childId,
                      vanOperatorId:
                          loggedInOperator!['VanOperatorID'].toString(),
                    );
                    Navigator.pop(context);
                    Navigator.pop(context, verificationResult);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Confirm Handover',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
    );
  }

  Future<void> _logHandover({
    required String parentId,
    required String childId,
    required String vanOperatorId,
  }) async {
    const apiUrl =
        'https://lightyellow-owl-629132.hostingersite.com/api/log-handover';

    await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'parent_id': parentId,
        'child_id': childId,
        'van_operator_id': vanOperatorId,
        'handover_time': DateTime.now().toIso8601String(),
      }),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _resetScanner() {
    if (!mounted) return;
    setState(() {
      isProcessing = false;
      verificationStatus = null;
      verificationResult = null;
    });
    cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Parent Authorization'),
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() => isFlashOn = !isFlashOn);
              cameraController.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _handleBarcode),

          // Scanner overlay
          _buildScannerOverlay(),

          // Status display
          if (verificationStatus != null)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  verificationStatus!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

          // Processing indicator
          if (isProcessing && verificationStatus == null)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(painter: _ScannerOverlayPainter()),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final cornerPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    const cornerLength = 20.0;

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
      paint,
    );

    // Draw corners
    _drawCorner(
      canvas,
      cornerPaint,
      0,
      0,
      cornerLength,
      cornerLength,
    ); // Top-left
    _drawCorner(
      canvas,
      cornerPaint,
      size.width,
      0,
      -cornerLength,
      cornerLength,
    ); // Top-right
    _drawCorner(
      canvas,
      cornerPaint,
      0,
      size.height,
      cornerLength,
      -cornerLength,
    ); // Bottom-left
    _drawCorner(
      canvas,
      cornerPaint,
      size.width,
      size.height,
      -cornerLength,
      -cornerLength,
    ); // Bottom-right
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double dx,
    double dy,
  ) {
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

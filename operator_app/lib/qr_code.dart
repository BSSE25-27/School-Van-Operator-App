import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:operator_app/login.dart';

class ParentQRScannerScreen extends StatefulWidget {
  final String childId;

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
  bool _shouldScan = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (!_shouldScan || isProcessing) return;

    final barcode = barcodeCapture.barcodes.first;
    if (barcode.rawValue == null) {
      _showError('Invalid QR code - no data found');
      return;
    }

    setState(() {
      isProcessing = true;
      verificationStatus = 'Verifying parent...';
      _shouldScan = false;
    });

    try {
      final qrData = jsonDecode(barcode.rawValue!);
      _validateQrData(qrData);

      final parentId = qrData['parent_id'].toString();
      final qrChildId = qrData['child_id'].toString();

      if (qrChildId != widget.childId) {
        throw Exception('This QR code is not for the selected child');
      }

      final vanOperatorId = loggedInOperator?['VanOperatorID']?.toString();
      if (vanOperatorId == null) {
        throw Exception('Operator not authenticated. Please log in again.');
      }

      final result = await _verifyPickup(
        parentId: parentId,
        childId: widget.childId,
        vanOperatorId: vanOperatorId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          verificationResult = {
            'parent_id': parentId,
            'parent_name': qrData['parent_name'],
            'child_name': result['child_name'],
          };
          verificationStatus = 'Verification successful';
        });

        await _showVerificationDialog(
          parentName: qrData['parent_name'],
          childName: result['child_name'],
        );
      } else {
        throw Exception(result['message'] ?? 'Verification failed');
      }
    } on FormatException catch (e) {
      _showError('Invalid QR format: ${e.message}');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  void _validateQrData(Map<String, dynamic> qrData) {
    if (qrData['parent_id'] == null || qrData['child_id'] == null) {
      throw const FormatException('Missing parent_id or child_id');
    }
    if (qrData['parent_name'] == null) {
      throw const FormatException('Missing parent_name');
    }
  }

  Future<Map<String, dynamic>> _verifyPickup({
    required String parentId,
    required String childId,
    required String vanOperatorId,
  }) async {
    final response = await http.post(
      Uri.parse('$serverUrl/api/verify-pickup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ParentID': parentId,
        'ChildID': childId,
        'VanOperatorID': vanOperatorId,
        'verification_time': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Server responded with status ${response.statusCode}');
    }
  }

  Future<void> _showVerificationDialog({
    required String parentName,
    required String childName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Verification Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent: $parentName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Child: $childName'),
                const SizedBox(height: 16),
                const Text('Please confirm the handover:'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Confirm Handover'),
              ),
            ],
          ),
    );

    // if (result == true) {
    //   await _completeHandover();
    // } else {
    //   _resetScanner();
    // }
  }

  Future<void> _completeHandover() async {
    if (verificationResult == null) return;

    setState(() => isProcessing = true);

    try {
      await _logHandover(
        parentId: verificationResult!['parent_id'],
        childId: widget.childId,
        vanOperatorId: loggedInOperator!['VanOperatorID'].toString(),
      );

      if (!mounted) return;
      Navigator.pop(context, verificationResult);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to log handover: ${e.toString()}');
      _resetScanner();
    }
  }

  Future<void> _logHandover({
    required String parentId,
    required String childId,
    required String vanOperatorId,
  }) async {
    final response = await http.post(
      Uri.parse('$serverUrl/api/log-handover'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'parent_id': parentId,
        'child_id': childId,
        'van_operator_id': vanOperatorId,
        'handover_time': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to log handover');
    }
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
      verificationStatus = null;
      verificationResult = null;
      _shouldScan = true;
    });
    cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Verification'),
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

          if (isProcessing && verificationStatus == null)
            const Center(child: CircularProgressIndicator()),
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
    _drawCorner(canvas, cornerPaint, 0, 0, cornerLength, cornerLength);
    _drawCorner(
      canvas,
      cornerPaint,
      size.width,
      0,
      -cornerLength,
      cornerLength,
    );
    _drawCorner(
      canvas,
      cornerPaint,
      0,
      size.height,
      cornerLength,
      -cornerLength,
    );
    _drawCorner(
      canvas,
      cornerPaint,
      size.width,
      size.height,
      -cornerLength,
      -cornerLength,
    );
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

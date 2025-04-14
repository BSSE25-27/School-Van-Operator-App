import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ParentQRScannerScreen extends StatefulWidget {
  final String childId; // The child we're trying to verify access for

  const ParentQRScannerScreen({super.key, required this.childId});

  @override
  State<ParentQRScannerScreen> createState() => _ParentQRScannerScreenState();
}

class _ParentQRScannerScreenState extends State<ParentQRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;
  bool isProcessing = false;
  bool isScanComplete = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (isProcessing || isScanComplete) return;

    final barcode = barcodeCapture.barcodes.first;
    if (barcode.rawValue == null) {
      _showError('No QR code detected');
      return;
    }

    setState(() => isProcessing = true);

    try {
      // Parse the parent QR data (expected format: "parentId:12345;name:John Doe")
      final parentData = _parseQRData(barcode.rawValue!);

      // Validate with backend
      final isValid = await _validateParentChildRelationship(
        parentId: parentData['parentId']!,
        childId: widget.childId,
      );

      if (!mounted) return;

      if (isValid) {
        Navigator.pop(context, {
          'status': 'verified',
          'parentData': parentData,
          'childId': widget.childId,
        });
      } else {
        _showError('This parent is not authorized for this child');
        _resetScanner();
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
      _resetScanner();
    }
  }

  Future<bool> _validateParentChildRelationship({
    required String parentId,
    required String childId,
  }) async {
    // Replace with your actual API endpoint
    const apiUrl = 'https://your-api.com/validate-parent-child';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'parent_id': parentId, 'child_id': childId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isValid'] ?? false;
    } else {
      throw Exception('Failed to validate: ${response.statusCode}');
    }
  }

  Map<String, String> _parseQRData(String data) {
    final parts = data.split(';');
    final result = <String, String>{};

    for (final part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        result[keyValue[0]] = keyValue[1];
      }
    }

    if (!result.containsKey('parentId')) {
      throw const FormatException('QR code missing parent ID');
    }

    return result;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetScanner() {
    if (!mounted) return;
    setState(() {
      isProcessing = false;
      isScanComplete = false;
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

          // Processing indicator
          if (isProcessing)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Validating parent credentials...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
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

// (Keep the same _ScannerOverlayPainter implementation from previous example)

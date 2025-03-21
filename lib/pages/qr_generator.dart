import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRGeneratorScreen extends StatefulWidget {
  @override
  _QRGeneratorScreenState createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  TextEditingController textController = TextEditingController();
  String qrData = "Enter text to generate QR Code";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrettyQrView.data(
              data: qrData,
              decoration: PrettyQrDecoration(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter text or URL",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  qrData = textController.text;
                });
              },
              child: Text("Generate QR Code"),
            ),
          ],
        ),
      ),
    );
  }
}

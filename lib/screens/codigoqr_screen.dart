import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey _qrKey = GlobalKey();
  String _qrCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escáner QR')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: _qrKey,
              onQRViewCreated: (controller) {
                controller.scannedDataStream.listen((scanData) {
                  setState(() {
                    _qrCode = scanData.code ?? '';
                  });
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Matrícula: $_qrCode'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey _qrKey = GlobalKey();
  String _qrCode = "";  // Variable para almacenar el texto del código QR escaneado.
  QRViewController? _controller; // Controlador del QR para pausar y reanudar.

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
                _controller = controller;
                // Escucha el stream del escáner para capturar el código QR.
                controller.scannedDataStream.listen((scanData) async {
                  // Pausa el escaneo después de leer el código.
                  _controller?.pauseCamera();
                  setState(() {
                    // Asigna el texto del QR escaneado a la variable _qrCode.
                    _qrCode = scanData.code ?? 'No se pudo leer el código QR'; 
                  });

                  // Si el código escaneado es una URL válida, muestra el diálogo para abrirla.
                  if (_qrCode.isNotEmpty && await canLaunchUrl(Uri.parse(_qrCode))) {
                    _showOpenURLDialog(_qrCode);  // Muestra el diálogo para abrir la URL.
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              // Muestra el contenido escaneado en pantalla.
              child: Text(
                'Contenido del QR: $_qrCode',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para mostrar un diálogo con la opción de abrir la URL.
  void _showOpenURLDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('URL escaneada'),
        content: Text('¿Quieres abrir esta URL?\n$url'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reanuda la cámara para seguir escaneando.
              _controller?.resumeCamera();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // Intenta abrir la URL en el navegador externo.
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication, // Abre en el navegador o aplicación externa.
                );
              } else {
                // Si no se puede abrir la URL, muestra un mensaje de error.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo abrir la URL')),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

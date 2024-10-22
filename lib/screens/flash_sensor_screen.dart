import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:torch_flashlight/torch_flashlight.dart';  // Asegúrate de que la librería esté correctamente instalada.

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  bool _isFlashOn = false;
  bool _isTorchAvailable = false;

  // Variables para almacenar los datos de los sensores
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;

  @override
  void initState() {
    super.initState();
    _checkTorchAvailability();  // Verificar si la linterna está disponible en el dispositivo
    _listenToSensors();
  }

  // Verificar si la linterna está disponible en el dispositivo
  Future<void> _checkTorchAvailability() async {
    bool isAvailable = await TorchFlashlight.isTorchFlashlightAvailable();
    setState(() {
      _isTorchAvailable = isAvailable;
    });
  }

  void _listenToSensors() {
    // Escuchar eventos del acelerómetro
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    });

    // Escuchar eventos del giroscopio
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    });

    // Escuchar eventos del magnetómetro
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometerValues = <double>[event.x, event.y, event.z];
      });
    });
  }

  // Encender o apagar la linterna
  Future<void> _toggleFlash() async {
    if (!_isTorchAvailable) {
      print("Linterna no disponible en este dispositivo.");
      return;
    }

    try {
      if (_isFlashOn) {
        await TorchFlashlight.disableTorchFlashlight();  // Método correcto para apagar la linterna.
      } else {
        await TorchFlashlight.enableTorchFlashlight();   // Método correcto para encender la linterna.
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print("Error al controlar la linterna: $e");
    }
  }

  // Mostrar los valores de los sensores en la pantalla
  Widget _buildSensorData(String sensorName, List<double>? values) {
    return Text(
      '$sensorName: ${values?.map((v) => v.toStringAsFixed(2)).toList() ?? 'Esperando...'}',
      style: const TextStyle(fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensores y Linterna')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleFlash,
              child: Text(_isFlashOn ? 'Apagar Linterna' : 'Encender Linterna'),
            ),
            const SizedBox(height: 20),
            _buildSensorData('Acelerómetro', _accelerometerValues),
            const SizedBox(height: 10),
            _buildSensorData('Giroscopio', _gyroscopeValues),
            const SizedBox(height: 10),
            _buildSensorData('Magnetómetro', _magnetometerValues),
          ],
        ),
      ),
    );
  }
}

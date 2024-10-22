import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class GeoLocatorScreen extends StatefulWidget {
  const GeoLocatorScreen({super.key});

  @override
  State<GeoLocatorScreen> createState() => _GeoLocatorScreenState();
}

class _GeoLocatorScreenState extends State<GeoLocatorScreen> {
  String _locationMessage = "";

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _locationMessage =
            "Lat: ${position.latitude}, Long: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        _locationMessage = "Error obtaining location: $e";
      });
    }
  }

  Future<void> _openInMaps() async {
    if (_locationMessage.isEmpty) {
      setState(() {
        _locationMessage = "No coordinates available to open in Maps.";
      });
      return;
    }

    // Extraer las coordenadas del mensaje de ubicación
    final parts = _locationMessage.split(", ");
    if (parts.length < 2) {
      setState(() {
        _locationMessage = "Invalid location format.";
      });
      return;
    }

    final String latitude = parts[0].split(": ")[1]; // Obtener la latitud
    final String longitude = parts[1].split(": ")[1]; // Obtener la longitud

    // Construir la URL de OpenStreetMap
    final String openStreetMapUrl =
        "https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=16/$latitude/$longitude";
    final Uri uri = Uri.parse(openStreetMapUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      setState(() {
        _locationMessage =
            'Could not open the map. Ensure you have a web browser installed.';
      });
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geolocalización")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text("Obtener Coordenadas GPS"),
            ),
            const SizedBox(height: 10),
            Text(_locationMessage),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openInMaps,
              child: const Text("Ver en OpenStreetMap"),
            ),
          ],
        ),
      ),
    );
  }
}

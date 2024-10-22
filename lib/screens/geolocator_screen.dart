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
  double? _latitude;  // Almacenar la latitud obtenida.
  double? _longitude; // Almacenar la longitud obtenida.

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationMessage =
            "Lat: ${_latitude}, Long: ${_longitude}";
      });
    } catch (e) {
      setState(() {
        _locationMessage = "Error obtaining location: $e";
      });
    }
  }

  Future<void> _openInMaps() async {
    if (_latitude == null || _longitude == null) {
      setState(() {
        _locationMessage = "No coordinates available to open in Maps.";
      });
      return;
    }

    // Construir la URL de Google Maps
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude";
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      // Intenta abrir la URL sin verificar `canLaunchUrl`
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      setState(() {
        _locationMessage =
            'Could not open the map. Ensure you have a web browser installed.';
      });
      print("Error opening URL: $e");
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
              child: const Text("Ver en Google Maps"),
            ),
          ],
        ),
      ),
    );
  }
}

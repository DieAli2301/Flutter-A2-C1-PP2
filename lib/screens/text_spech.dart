import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  _TextToSpeechScreenState createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();

  void _speak() async {
    await _flutterTts.speak(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text to Speech')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Ingrese texto'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _speak,
            child: const Text('Reproducir Texto'),
          ),
        ],
      ),
    );
  }
}

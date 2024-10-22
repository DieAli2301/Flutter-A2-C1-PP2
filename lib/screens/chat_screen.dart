import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatbotPage(),
    );
  }
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyCmj_VCtdn5rSAK3X3Pp_Ic9rfBA2VCwAY'; // API KEY

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final FocusNode _focusNode = FocusNode();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool _isConnected = true;
  bool _isThinking = false;
  final List<String> _emojis = ['👾', '🎃', '🦾', '😀', '👻'];
   bool _isMessageValid(String message) {
    return message.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _loadMessages();  // Cargar mensajes guardados
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  String _getRandomEmoji() {
    final random = Random();
    return _emojis[random.nextInt(_emojis.length)];
  }

  Future<void> _saveMessages() async { // Guardar mensajes
    final prefs = await SharedPreferences.getInstance(); // Crear instancia de SharedPreferences
    final String encodedMessages = json.encode(_messages);// Codificar los mensajes
    prefs.setString('messages', encodedMessages);// Guardar los mensajes
  }

  Future<void> _loadMessages() async { // Cargar mensajes
  final prefs = await SharedPreferences.getInstance(); 
  final String? encodedMessages = prefs.getString('messages'); 
  
  if (encodedMessages != null) {
    final List<dynamic> decodedMessages = json.decode(encodedMessages);
    
    setState(() {
      _messages.clear();
      _messages.addAll(
        decodedMessages.map((message) { 
          return {
            'sender': message['sender'].toString(),
            'message': message['message'].toString(),
          };
        }).toList(),
      );
    });
  }
}


Future<void> sendMessage(String message) async { 
  setState(() {
    _messages.add({"sender": "user", "message": message});
    _isThinking = true;
    _controller.clear();
    _saveMessages();  // Guardar mensajes inmediatamente después de agregar el mensaje del usuario
  });

  Future.microtask(() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final botMessage = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.toString() ?? 'No response';
        final botMessageWithEmoji = '$botMessage ${_getRandomEmoji()}';

        setState(() {
          _messages.add({"sender": "bot", "message": botMessageWithEmoji});
          _saveMessages();  // Guardar los mensajes inmediatamente después de recibir la respuesta del bot
        });
      } else {
        setState(() {
          _messages.add({
            "sender": "bot",
            "message": "Error: ${response.statusCode} - ${response.body}"
          });
          _saveMessages();  // Guardar los mensajes si hay un error
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"sender": "bot", "message": "Error: $e"});
        _saveMessages();  // Guardar los mensajes si hay una excepción
      });
    } finally {
      setState(() {
        _isThinking = false;
      });
    }
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot Mejorado'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _messages.clear();
                _saveMessages();  // Limpiar mensajes guardados
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isThinking && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Bot escribiendo',
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ),
                  );
                }

                final message = _messages[index];
                final isUserMessage = message['sender'] == 'user';

                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.deepPurple[300]
                          : Color.fromARGB(255, 250, 161, 244),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isUserMessage ? 15 : 0),
                        topRight: const Radius.circular(15),
                        bottomLeft: const Radius.circular(15),
                        bottomRight: Radius.circular(isUserMessage ? 0 : 15),
                      ),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: isUserMessage ? Colors.white : Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Escribir mensaje',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: _isConnected ? Colors.greenAccent : Colors.grey,
                  onPressed: _isConnected
                      ? () {
                          final text = _controller.text;
                          if (_isMessageValid(text)) {
                            sendMessage(text.trim());
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

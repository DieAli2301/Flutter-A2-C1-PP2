import 'package:flutter/material.dart';




class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido a la UP'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/student_form');
          },
          child: Text('Ir al Registro de Alumnos'),
        ),
      ),
    );
  }
}

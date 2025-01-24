import 'package:evalucion_consumo/controllers/json_controller.dart';
import 'package:evalucion_consumo/views/verduras_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  final githubUrl =
      'https://raw.githubusercontent.com/DylanGReinosoT/Examen_Practico_Moviles/main/Verduras.json';
  final githubToken = 'your_github_token'; // Agrega tu token aquí

  runApp(MyApp(controller: JsonController(githubUrl, githubToken)));
}

class MyApp extends StatelessWidget {
  final JsonController controller;

  MyApp({required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verduras App',
      home: VerduraListScreen(controller: controller),
    );
  }
}

import 'dart:convert';
import 'package:evalucion_consumo/models/verdura_model.dart';
import 'package:http/http.dart' as http;

class JsonController {
  List<Verdura> _verduras = [];
  final String githubUrl;
  final String githubToken;

  JsonController(this.githubUrl, this.githubToken);

  // Leer verduras desde el archivo JSON en GitHub
  Future<List<Verdura>> fetchVerduras() async {
    final response = await http.get(Uri.parse(githubUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      _verduras = jsonData.map((json) => Verdura.fromJson(json)).toList();
      return _verduras;
    } else {
      throw Exception(
          'Error al cargar el archivo JSON desde GitHub: ${response.statusCode}');
    }
  }

  // Actualizar el archivo JSON en GitHub
  Future<void> actualizarArchivo() async {
    final url = githubUrl.replaceFirst(
        'raw.githubusercontent.com', 'api.github.com/repos');
    final uri = Uri.parse(url);

    final jsonContent =
        json.encode(_verduras.map((verdura) => verdura.toJson()).toList());
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'token $githubToken',
        'Content-Type': 'application/json',
      },
      body: jsonContent,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Error al actualizar el archivo JSON en GitHub: ${response.statusCode}');
    }
  }

  // Crear una nueva verdura
  void addVerdura(Verdura verdura) {
    _verduras.add(verdura);
    actualizarArchivo();
  }

  // Actualizar una verdura
  void updateVerdura(int codigo, Verdura verdura) {
    final index = _verduras.indexWhere((v) => v.codigo == codigo);
    if (index != -1) {
      _verduras[index] = verdura;
      actualizarArchivo();
    } else {
      throw Exception('Índice fuera de rango');
    }
  }

  // Eliminar una verdura
  void deleteVerdura(int codigo) {
    _verduras.removeWhere((v) => v.codigo == codigo);
    actualizarArchivo();
  }

  // Obtener todas las verduras
  List<Verdura> getAllVerduras() {
    return _verduras;
  }
}

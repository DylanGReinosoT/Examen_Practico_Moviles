import 'package:evalucion_consumo/controllers/json_controller.dart';
import 'package:evalucion_consumo/models/verdura_model.dart';
import 'package:flutter/material.dart';

class VerduraListScreen extends StatefulWidget {
  final JsonController controller;

  VerduraListScreen({required this.controller});

  @override
  _VerduraListScreenState createState() => _VerduraListScreenState();
}

class _VerduraListScreenState extends State<VerduraListScreen> {
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Método para cargar los datos desde el servicio
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await widget.controller.fetchVerduras();
    } catch (e) {
      _errorMessage = e.toString();
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Método para mostrar el diálogo para agregar o editar
  Future<void> _showFormDialog({Verdura? verdura}) async {
    final isEdit = verdura != null;
    final TextEditingController codigoController =
        TextEditingController(text: isEdit ? verdura.codigo.toString() : '');
    final TextEditingController descripcionController =
        TextEditingController(text: isEdit ? verdura.descripcion : '');
    final TextEditingController precioController =
        TextEditingController(text: isEdit ? verdura.precio.toString() : '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Editar Verdura' : 'Agregar Verdura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Código'),
                enabled: !isEdit, // El código no se puede editar
              ),
              TextField(
                controller: descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Precio'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final int codigo = int.tryParse(codigoController.text) ?? 0;
                final String descripcion = descripcionController.text;
                final double precio =
                    double.tryParse(precioController.text) ?? 0.0;

                if (codigo > 0 && descripcion.isNotEmpty && precio > 0.0) {
                  final nuevaVerdura = Verdura(
                    codigo: codigo,
                    descripcion: descripcion,
                    precio: precio,
                  );

                  setState(() {
                    if (isEdit) {
                      widget.controller.updateVerdura(codigo, nuevaVerdura);
                    } else {
                      widget.controller.addVerdura(nuevaVerdura);
                    }
                  });

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Por favor completa todos los campos correctamente.')),
                  );
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar una verdura
  void _deleteVerdura(int codigo) {
    setState(() {
      widget.controller.deleteVerdura(codigo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final verduras = widget.controller.getAllVerduras();

    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD de Verduras'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData, // Recargar datos desde el servicio
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carga
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage)) // Mensaje de error
              : verduras.isEmpty
                  ? Center(child: Text('No hay verduras disponibles'))
                  : ListView.builder(
                      itemCount: verduras.length,
                      itemBuilder: (context, index) {
                        final verdura = verduras[index];
                        return ListTile(
                          title: Text(verdura.descripcion),
                          subtitle: Text(
                              'Precio: \$${verdura.precio.toStringAsFixed(2)}'),
                          leading: CircleAvatar(
                            child: Text('${verdura.codigo}'),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showFormDialog(
                                    verdura: verdura), // Editar verdura
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteVerdura(
                                    verdura.codigo), // Eliminar verdura
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(), // Mostrar diálogo para agregar
        child: Icon(Icons.add),
        tooltip: 'Agregar Verdura',
      ),
    );
  }
}

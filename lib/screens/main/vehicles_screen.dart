import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VehiclesScreen extends StatefulWidget {
  final String token;
  final String role;
  final int userProfileId;

  const VehiclesScreen({
    super.key,
    required this.token,
    required this.role,
    required this.userProfileId,
  });

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<dynamic> vehicles = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController anioController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print('Token recibido en VehiclesScreen: ${widget.token}'); // Depuración
    fetchVehicles();
  }

  @override
  void dispose() {
    marcaController.dispose();
    modeloController.dispose();
    colorController.dispose();
    anioController.dispose();
    super.dispose();
  }

  Future<void> fetchVehicles() async {
    try {
      // Prueba con 'Token' primero
      var response = await http.get(
        Uri.parse('http://192.168.1.10:8080/api/vehicles/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${widget.token}',
        },
      );

      print('Estado de la respuesta /vehicles/ (Token): ${response.statusCode}'); // Depuración
      print('Cuerpo de la respuesta (Token): ${response.body}'); // Depuración
      print('Encabezado Authorization enviado: Token ${widget.token}'); // Depuración

      if (response.statusCode == 401) {
        // Si falla con 'Token', prueba con 'Bearer'
        response = await http.get(
          Uri.parse('http://192.168.1.10:8080/api/vehicles/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
        );

        print('Estado de la respuesta /vehicles/ (Bearer): ${response.statusCode}'); // Depuración
        print('Cuerpo de la respuesta (Bearer): ${response.body}'); // Depuración
        print('Encabezado Authorization enviado: Bearer ${widget.token}'); // Depuración
      }

      if (response.statusCode == 200) {
        setState(() {
          vehicles = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al cargar vehículos: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Excepción en fetchVehicles: $e'); // Depuración
      setState(() {
        errorMessage = 'Error al cargar vehículos: $e';
        isLoading = false;
      });
    }
  }

  Future<void> saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (marcaController.text.isEmpty ||
        modeloController.text.isEmpty ||
        colorController.text.isEmpty ||
        anioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    try {
      int anio = int.parse(anioController.text);
      if (anio < 1900 || anio > DateTime.now().year) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Año inválido')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.10:8080/api/vehicles/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${widget.token}', // Cambia a 'Bearer' si es necesario
        },
        body: json.encode({
          'marca': marcaController.text,
          'modelo': modeloController.text,
          'color': colorController.text,
          'anio': anio,
          'user_profile': widget.userProfileId,
        }),
      );

      print('Estado de la respuesta POST /vehicles/: ${response.statusCode}'); // Depuración
      print('Cuerpo de la respuesta POST: ${response.body}'); // Depuración

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehículo guardado exitosamente')),
        );
        marcaController.clear();
        modeloController.clear();
        colorController.clear();
        anioController.clear();
        fetchVehicles(); // Actualizar lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar vehículo: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Excepción en saveVehicle: $e'); // Depuración
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar vehículo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    // Formulario para agregar vehículo
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Agregar Nuevo Vehículo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: marcaController,
                                  decoration: InputDecoration(
                                    labelText: 'Marca',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa la marca';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: modeloController,
                                  decoration: InputDecoration(
                                    labelText: 'Modelo',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa el modelo';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: colorController,
                                  decoration: InputDecoration(
                                    labelText: 'Color',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa el color';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: anioController,
                                  decoration: InputDecoration(
                                    labelText: 'Año',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa el año';
                                    }
                                    try {
                                      int anio = int.parse(value);
                                      if (anio < 1900 || anio > DateTime.now().year) {
                                        return 'Año inválido';
                                      }
                                    } catch (e) {
                                      return 'El año debe ser un número válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: saveVehicle,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Guardar Vehículo'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Lista de vehículos
                    Expanded(
                      child: vehicles.isEmpty
                          ? const Center(child: Text('No hay vehículos registrados'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: vehicles.length,
                              itemBuilder: (context, index) {
                                final vehicle = vehicles[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16.0),
                                    title: Text(
                                      '${vehicle['marca']} ${vehicle['modelo']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Año: ${vehicle['anio']} | Color: ${vehicle['color']}'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
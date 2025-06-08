import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class InfraccionesScreen extends StatefulWidget {
  final String token;

  const InfraccionesScreen({super.key, required this.token});

  @override
  State<InfraccionesScreen> createState() => _InfraccionesScreenState();
}

class _InfraccionesScreenState extends State<InfraccionesScreen> {
  List<dynamic> infracciones = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime? selectedDate;
  String? selectedPagado;

  @override
  void initState() {
    super.initState();
    fetchInfracciones();
  }

  Future<void> fetchInfracciones({String? fecha, String? pagado}) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      var url = Uri.parse('http://192.168.1.9:8080/api/infracciones/');
      if (fecha != null || pagado != null) {
        final queryParams = <String, String>{};
        if (fecha != null) queryParams['fecha'] = fecha;
        if (pagado != null) queryParams['pagado'] = pagado;
        url = Uri.http(url.authority, url.path, queryParams);
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          infracciones = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al cargar infracciones: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar infracciones: $e';
        isLoading = false;
      });
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      final formatter = DateFormat('yyyy-MM-dd');
      fetchInfracciones(
        fecha: formatter.format(picked),
        pagado: selectedPagado,
      );
    }
  }

  void _applyFilters() {
    fetchInfracciones(
      fecha: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null,
      pagado: selectedPagado,
    );
  }

  void _clearFilters() {
    setState(() {
      selectedDate = null;
      selectedPagado = null;
    });
    fetchInfracciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Fecha',
                              prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
                              filled: true,
                              fillColor: Colors.green.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              hintText: selectedDate == null
                                  ? 'Selecciona una fecha'
                                  : DateFormat('dd/MM/yyyy').format(selectedDate!),
                            ),
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedPagado,
                            decoration: InputDecoration(
                              labelText: 'Estado',
                              prefixIcon: const Icon(Icons.check_circle, color: Colors.green),
                              filled: true,
                              fillColor: Colors.green.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Todos')),
                              DropdownMenuItem(value: 'true', child: Text('Pagado')),
                              DropdownMenuItem(value: 'false', child: Text('No Pagado')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedPagado = value;
                              });
                              _applyFilters();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Limpiar Filtros', style: TextStyle(color: Colors.green)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => fetchInfracciones(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : infracciones.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warning, size: 80, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No hay infracciones registradas',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => fetchInfracciones(
                              fecha: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null,
                              pagado: selectedPagado,
                            ),
                            color: Colors.green,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: infracciones.length,
                              itemBuilder: (context, index) {
                                final infraccion = infracciones[index];
                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green.shade100,
                                      child: const Icon(Icons.warning, color: Colors.green),
                                    ),
                                    title: Text(
                                      'Placa: ${infraccion['placa']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(infraccion['fecha_hora']))}'),
                                        Text('Estado: ${infraccion['pagado'] ? 'Pagado' : 'No Pagado'}'),
                                        Text('Coordenadas: ${infraccion['latitud']}, ${infraccion['longitud']}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
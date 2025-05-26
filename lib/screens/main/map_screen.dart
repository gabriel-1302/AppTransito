import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final Set<Polygon> _polygons = {}; // Para la zona restringida
  final Set<Polyline> _polylines = {}; // Para las franjas rojas
  String? _errorMessage; // Para mostrar errores de la API o ubicación
  LocationData? _currentLocation; // Para la ubicación actual
  final Location _location = Location();

  // API para restricciones de estacionamiento
  final String restrictionsApiUrl = 'http://192.168.1.10:8000/api/zonas-restringidas/'; // Para dispositivo físico
  // final String restrictionsApiUrl = 'http://10.0.2.2:8000/api/restrictions/'; // Descomenta para emulador

  // Modo de visualización: 'restrictions' (calles), 'zone' (polígono), 'both' (ambos)
  String _displayMode = 'both';

  @override
  void initState() {
    super.initState();
    _loadRestrictions(); // Carga las calles restringidas desde la API
    _loadRestrictedZone(); // Carga la zona restringida con coordenadas estáticas
    _getCurrentLocation(); // Obtiene la ubicación actual
  }

  // Obtener la ubicación actual
  Future<void> _getCurrentLocation() async {
    print('Iniciando obtención de ubicación...');
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      print('Servicio de ubicación habilitado: $serviceEnabled');
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        print('Solicitando servicio de ubicación: $serviceEnabled');
        if (!serviceEnabled) {
          setState(() {
            _errorMessage = 'El servicio de ubicación está deshabilitado.';
          });
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      print('Estado del permiso: $permissionGranted');
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        print('Solicitando permiso: $permissionGranted');
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            _errorMessage = 'Permiso de ubicación denegado.';
          });
          return;
        }
      }

      final locationData = await _location.getLocation();
      print('Ubicación obtenida: lat=${locationData.latitude}, lon=${locationData.longitude}');
      setState(() {
        _currentLocation = locationData;
      });

      if (_controller != null && locationData.latitude != null && locationData.longitude != null) {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(locationData.latitude!, locationData.longitude!),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error al obtener ubicación: $e');
      setState(() {
        _errorMessage = 'Error al obtener ubicación: $e';
      });
    }
  }

  // Cargar restricciones de estacionamiento desde la API
  Future<void> _loadRestrictions() async {
    try {
      print('Intentando cargar restricciones desde: $restrictionsApiUrl');
      final response = await http.get(Uri.parse(restrictionsApiUrl));
      print('Código de estado: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Datos recibidos: $data');

        if (data.isEmpty) {
          setState(() {
            _errorMessage = 'No se encontraron restricciones.';
          });
          return;
        }

        setState(() {
          _polylines.clear(); // Limpiar líneas anteriores
          for (var item in data) {
            if (item['coordenada1_lat'] != null &&
                item['coordenada1_lon'] != null &&
                item['coordenada2_lat'] != null &&
                item['coordenada2_lon'] != null) {
              _polylines.add(
                Polyline(
                  polylineId: PolylineId('restriction_${item['id']}'),
                  points: [
                    LatLng(item['coordenada1_lat'], item['coordenada1_lon']),
                    LatLng(item['coordenada2_lat'], item['coordenada2_lon']),
                  ],
                  color: Colors.red,
                  width: 6,
                ),
              );
            } else {
              print('Datos incompletos en: $item');
            }
          }
          _errorMessage = _polylines.isEmpty
              ? 'No se pudieron cargar restricciones válidas.'
              : null;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar restricciones: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error de conexión: $e');
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    }
  }

  // Cargar coordenadas estáticas de la zona restringida
  void _loadRestrictedZone() {
    final List<LatLng> polygonPoints = [
      LatLng(-19.048, -65.260), // Punto 1
      LatLng(-19.048, -65.258), // Punto 2
      LatLng(-19.050, -65.258), // Punto 3
      LatLng(-19.050, -65.260), // Punto 4
      LatLng(-19.049, -65.259), // Punto 5
    ];

    setState(() {
      _polygons.clear(); // Limpiar polígonos anteriores
      _polygons.add(
        Polygon(
          polygonId: const PolygonId('restricted_zone'),
          points: polygonPoints,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          strokeWidth: 2,
        ),
      );
    });
  }

  // Alternar modo de visualización
  void _toggleDisplayMode() {
    setState(() {
      if (_displayMode == 'both') {
        _displayMode = 'restrictions';
      } else if (_displayMode == 'restrictions') {
        _displayMode = 'zone';
      } else {
        _displayMode = 'both';
      }
    });
  }

  // Obtener el icono según el modo
  IconData _getModeIcon() {
    switch (_displayMode) {
      case 'restrictions':
        return Icons.directions;
      case 'zone':
        return Icons.crop_square;
      default:
        return Icons.layers;
    }
  }

  // Obtener los polylines según el modo
  Set<Polyline> _getVisiblePolylines() {
    return _displayMode == 'restrictions' || _displayMode == 'both' ? _polylines : {};
  }

  // Obtener los polígonos según el modo
  Set<Polygon> _getVisiblePolygons() {
    return _displayMode == 'zone' || _displayMode == 'both' ? _polygons : {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-19.048, -65.260),
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              if (_currentLocation != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                      zoom: 15,
                    ),
                  ),
                );
              }
            },
            polygons: _getVisiblePolygons(), // Muestra el polígono según el modo
            polylines: _getVisiblePolylines(), // Muestra las franjas según el modo
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 50,
            left: 10,
            child: FloatingActionButton(
              onPressed: _toggleDisplayMode,
              backgroundColor: Colors.white,
              child: Icon(
                _getModeIcon(),
                color: Colors.black,
              ),
            ),
          ),
          if (_errorMessage != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                color: Colors.red.withOpacity(0.8),
                padding: const EdgeInsets.all(8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
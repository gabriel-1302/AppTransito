import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/zona_restringida.dart';
import '../../services/api_service_zonas.dart';
import '../../utils/location_utils.dart';
import '../../widgets/loading_indicator.dart';
import '../../services/api_service_zonas.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(-19.047961, -65.260443),
    zoom: 17,
  );
  
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  List<ZonaRestringida> _zonasRestringidas = [];
  final ApiServiceZonas _apiService = ApiServiceZonas();

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _fetchZonasRestringidas();
  }

  Future<void> _loadLocation() async {
    final position = await LocationUtils.determinePosition(context);
    if (position != null) {
      setState(() {
        _currentPosition = position;
        _markers = {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Mi ubicación'),
          ),
        };
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchZonasRestringidas() async {
    try {
      final zonasRestringidas = await _apiService.getZonasRestringidas();
      setState(() {
        _zonasRestringidas = zonasRestringidas;
      });
      _addNoParkingZones();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar zonas restringidas: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Si falla la API, usamos las zonas estáticas como fallback
        _addStaticNoParkingZones();
      }
    }
  }

  void _addStaticNoParkingZones() {
    // Código original para zonas estáticas como fallback
    final List<LatLng> zone1 = [
      const LatLng(-19.047961, -65.260443),
      const LatLng(-19.048707, -65.259516),
    ];
    
    final List<LatLng> zone2 = [
      const LatLng(-19.047232, -65.261388),
      const LatLng(-19.047948, -65.260511),
    ];
    
    final List<LatLng> zone3 = [
      const LatLng(-19.048087, -65.262121),
      const LatLng(-19.047228, -65.261365),
    ];
    
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('no_parking_zone_1'),
          points: zone1,
          color: const Color.fromARGB(255, 255, 0, 0),
          width: 15,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
        Polyline(
          polylineId: const PolylineId('no_parking_zone_2'),
          points: zone2,
          color: const Color.fromARGB(255, 255, 0, 0),
          width: 15,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
        Polyline(
          polylineId: const PolylineId('no_parking_zone_3'),
          points: zone3,
          color: const Color.fromARGB(255, 255, 0, 0),
          width: 15,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
      };
      _isLoading = false;
    });
  }

  void _addNoParkingZones() {
    final Set<Polyline> polylines = {};
    
    // Convertir las zonas de la API a polilíneas
    for (var i = 0; i < _zonasRestringidas.length; i++) {
      final zona = _zonasRestringidas[i];
      
      List<LatLng> points = [
        LatLng(zona.coordenada1_lat, zona.coordenada1_lon),
        LatLng(zona.coordenada2_lat, zona.coordenada2_lon),
      ];
      
      polylines.add(
        Polyline(
          polylineId: PolylineId('no_parking_zone_$i'),
          points: points,
          color: const Color.fromARGB(255, 255, 0, 0),
          width: 10,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
      );
    }
    
    setState(() {
      _polylines = polylines;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingIndicator()
        : Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: _fetchZonasRestringidas,
                  tooltip: 'Actualizar zonas',
                  child: const Icon(Icons.refresh),
                ),
              ),
            ],
          );
  }
}
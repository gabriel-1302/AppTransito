import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/menu_button.dart';
import 'map_screen.dart';
import 'info_screen.dart';
import 'admin_screen.dart';
import '../auth/auth_screen.dart';

class MainScreen extends StatefulWidget {
  final String role;

  const MainScreen({super.key, required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isMenuOpen = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    
    // Pantallas base para todos los usuarios
    _screens = [
      const MapScreen(), // Índice 0
      InfoScreen(
        title: 'Código de Tránsito', 
        message: AppConstants.codigoTransito,
      ), // Índice 1
      const InfoScreen(
        title: 'Horarios', 
        message: AppConstants.horarios,
      ), // Índice 2
      InfoScreen(
        title: 'Ayuda', 
        message: AppConstants.contactoAyuda,
      ), // Índice 3
      
      // Pantalla de Admin solo para policías (índice 4)
      if (widget.role == Roles.policia)
        const AdminScreen(),
    ];

    // Mostrar mensaje de bienvenida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenido ${widget.role == Roles.ciudadano ? 'Ciudadano' : 'Policía'}'),
          backgroundColor: roleColors[widget.role],
        ),
      );
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _changeScreen(int index) {
    setState(() {
      _currentIndex = index;
      _isMenuOpen = false;
    });
  }

  String _getAppBarTitle() {
    if (_currentIndex == 0) return 'Mapa Principal';
    if (_currentIndex == 4) return 'Panel de Administración';
    return _screens[_currentIndex].toStringShort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: _toggleMenu,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              label: Text(
                widget.role == Roles.ciudadano ? 'Ciudadano' : 'Policía',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: roleColors[widget.role],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _screens[_currentIndex],
          if (_isMenuOpen)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 200,
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    MenuButton(
                      icon: Icons.map,
                      label: 'Mapa',
                      isActive: _currentIndex == 0,
                      onPressed: () => _changeScreen(0),
                    ),
                    MenuButton(
                      icon: Icons.info,
                      label: 'Información',
                      isActive: _currentIndex == 1,
                      onPressed: () => _changeScreen(1),
                    ),
                    MenuButton(
                      icon: Icons.timelapse,
                      label: 'Horarios',
                      isActive: _currentIndex == 2,
                      onPressed: () => _changeScreen(2),
                    ),
                    MenuButton(
                      icon: Icons.help,
                      label: 'Ayuda',
                      isActive: _currentIndex == 3,
                      onPressed: () => _changeScreen(3),
                    ),
                    
                    // Botón de Admin solo para policías
                    if (widget.role == Roles.policia)
                      MenuButton(
                        icon: Icons.admin_panel_settings,
                        label: 'Admin',
                        isActive: _currentIndex == 4,
                        onPressed: () => _changeScreen(4),
                      ),
                    
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar Sesión'),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
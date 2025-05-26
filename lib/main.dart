import 'package:flutter/material.dart';
import 'app.dart';
import 'services/api_service_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ApiServiceAuth apiService = ApiServiceAuth();

  // Comprobar si ya está logueado
  bool isLoggedIn = await apiService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}
// lib/services/api_service_auth.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiServiceAuth {
  // Singleton
  static final ApiServiceAuth _instance = ApiServiceAuth._internal();
  factory ApiServiceAuth() => _instance;
  ApiServiceAuth._internal();

  // Almacenamiento seguro para el token
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // URL de login extraída de ApiConstants
  final String _loginUrl = ApiConstants.loginUrl;

  /// Autentica al usuario contra la API de login.
  /// Retorna un mapa con:
  ///  - 'success': bool
  ///  - 'role': String (solo si success = true)
  ///  - 'message': String
  Future<Map<String, dynamic>> authenticate(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Guarda el token si está presente
        if (data.containsKey('token')) {
          await _storage.write(key: 'token', value: data['token']);
        }

        return {
          'success': true,
          'role': data['role'] as String,
          'message': 'Inicio de sesión exitoso',
        };
      } else {
        // Intenta extraer mensaje de error de la respuesta
        String errorMsg = 'Error al autenticar: ${response.statusCode}';
        try {
          final Map<String, dynamic> err = json.decode(response.body);
          errorMsg = err['message'] ?? errorMsg;
        } catch (_) {}
        return {
          'success': false,
          'message': errorMsg,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Excepción al autenticar: $e',
      };
    }
  }

  /// Comprueba si existe un token guardado (sesión activa)
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  /// Elimina el token guardado, cerrando la sesión
  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  /// (Opcional) Obtiene el token actual
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}

import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/dashboard_data.dart';
import '../models/delivery.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const _tokenKey = 'auth_token';
  static const _storage = FlutterSecureStorage();
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  final http.Client _client = http.Client();
  late final Uri _baseUri = Uri.parse(
    _configuredBaseUrl.isNotEmpty
        ? _configuredBaseUrl
        : defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3000/api'
        : 'http://localhost:3000/api',
  );

  Future<bool> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return false;

    try {
      await get('/usuarios');
      return true;
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await logout();
        return false;
      }
      return true;
    }
  }

  Future<AppUser> login({
    required String userCode,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login',
      body: {'cod_user': userCode.trim(), 'contraseña': password},
      authenticated: false,
    );
    final token = data['token'];
    final userData = data['usuario'];
    if (token is! String ||
        token.isEmpty ||
        userData is! Map<String, dynamic>) {
      throw const ApiException('El servidor devolvió una sesión inválida.');
    }
    await _storage.write(key: _tokenKey, value: token);
    return AppUser.fromJson(userData);
  }

  Future<AppUser> register({
    required String userCode,
    required String name,
    required String password,
  }) async {
    await _request(
      'POST',
      '/auth/registro',
      body: {
        'cod_user': userCode.trim(),
        'nombre': name.trim(),
        'tipo': 'usuario',
        'contraseña': password,
      },
      authenticated: false,
    );
    try {
      return await login(userCode: userCode, password: password);
    } on ApiException catch (error) {
      throw ApiException(
        'La cuenta se creó, pero no se pudo iniciar sesión automáticamente. '
        'Intenta ingresar desde el login. ${error.message}',
        statusCode: error.statusCode,
      );
    }
  }

  Future<DashboardData> loadDashboard() async {
    final responses = await Future.wait([
      get('/usuarios'),
      get('/usuarios/me/metricas'),
      get('/ranking'),
      get('/usuarios/me/historial?pagina=1&limite=10'),
    ]);

    final user = AppUser.fromJson(responses[0]);
    final metrics = responses[1];
    final ranking = responses[2];
    final history = responses[3];

    final historyPage = _parseHistoryPage(history);
    final topData = ranking['usuario'];
    if (topData != null && topData is! Map<String, dynamic>) {
      throw const ApiException('El servidor devolvió datos incompletos.');
    }
    return DashboardData(
      user: user,
      metrics: UserMetrics.fromJson(metrics),
      rankingPosition: topData is Map<String, dynamic>
          ? _intOrNull(topData['posicion'])
          : null,
      deliveries: historyPage.deliveries,
      historyTotal: historyPage.total,
    );
  }

  Future<HistoryPage> loadHistoryPage(int page) async {
    final result = await get('/usuarios/me/historial?pagina=$page&limite=10');
    return _parseHistoryPage(result);
  }

  Future<Map<String, dynamic>> get(String path) =>
      _request('GET', path, authenticated: true);

  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
    required bool authenticated,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated) {
      final token = await _storage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        throw const ApiException('Tu sesión expiró. Inicia sesión nuevamente.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final normalizedBase = _baseUri.toString().replaceAll(RegExp(r'/+$'), '');
    final relativePath = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('$normalizedBase/$relativePath');
    late final http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      response = await http.Response.fromStream(streamed);
    } on http.ClientException {
      throw ApiException(
        'No se pudo conectar con el servidor (${_baseUri.host}).',
      );
    } on TimeoutException {
      throw const ApiException(
        'La solicitud tardó demasiado. Inténtalo otra vez.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'El servidor devolvió una respuesta inválida (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        'El servidor devolvió una respuesta inesperada.',
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['ok'] != true) {
      final error = decoded['mensaje'] ?? decoded['error'];
      throw ApiException(
        error is String && error.isNotEmpty
            ? error
            : 'No se pudo completar la solicitud (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic>) return data;
    throw ApiException(
      'El servidor devolvió datos en un formato inesperado.',
      statusCode: response.statusCode,
    );
  }

  static int? _intOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static HistoryPage _parseHistoryPage(Map<String, dynamic> json) {
    final records = json['registros'];
    final pagination = json['paginacion'];
    if (records is! List) {
      throw const ApiException('El servidor devolvió un historial inválido.');
    }
    final total =
        _intOrNull(pagination is Map ? pagination['total'] : null) ??
        records.length;
    return HistoryPage(
      deliveries: records
          .whereType<Map<String, dynamic>>()
          .map(Delivery.fromJson)
          .toList(growable: false),
      total: total,
    );
  }
}

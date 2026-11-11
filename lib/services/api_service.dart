import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/dashboard_data.dart';
import '../models/delivery.dart';
import '../models/monthly_recycler.dart';

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

  Future<void> requestRegistrationCode({required String email}) async {
    await _request(
      'POST',
      '/auth/registro/codigo',
      body: {'correo_institucional': email.trim()},
      authenticated: false,
    );
  }

  Future<String> verifyCode({
    required String email,
    required String code,
    required String purpose,
  }) async {
    final data = await _request(
      'POST',
      '/auth/verificar-codigo',
      body: {
        'correo_institucional': email.trim(),
        'codigo_verificacion': code.trim(),
        'proposito': purpose,
      },
      authenticated: false,
    );
    final securityToken = data['token_seguridad'];
    if (securityToken is! String || securityToken.isEmpty) {
      throw const ApiException(
        'El servidor no devolvió un token de verificación válido.',
      );
    }
    return securityToken;
  }

  Future<AppUser> register({
    required String userCode,
    required String name,
    required String password,
    required String email,
    required String securityToken,
  }) async {
    await _request(
      'POST',
      '/auth/registro',
      body: {
        'cod_user': userCode.trim(),
        'nombre': name.trim(),
        'tipo': 'usuario',
        'contraseña': password,
        'correo_institucional': email.trim(),
        'token_seguridad': securityToken,
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

  Future<void> requestPasswordRecoveryCode({required String email}) async {
    await _request(
      'POST',
      '/auth/recuperar-contrasena',
      body: {'correo_institucional': email.trim()},
      authenticated: false,
    );
  }

  Future<void> changePassword({
    required String userCode,
    required String password,
    required String securityToken,
  }) async {
    await _request(
      'POST',
      '/auth/modificar-contrasena',
      body: {
        'cod_user': userCode.trim(),
        'nueva_contraseña': password,
        'token_seguridad': securityToken,
      },
      authenticated: false,
    );
  }

  Future<AppUser> updateProfile({required String name}) async {
    final data = await _request(
      'PATCH',
      '/usuarios/me',
      body: {'nombre': name.trim()},
      authenticated: true,
    );

    final userData = data['usuario'] ?? data;
    if (userData is! Map<String, dynamic>) {
      throw const ApiException('El servidor devolvió un formato de usuario inválido.');
    }

    return AppUser.fromJson(userData);
  }

  Future<DashboardData> loadDashboard() async {
    final responses = await Future.wait([
      get('/usuarios'),
      get('/usuarios/me/metricas'),
      get('/ranking'),
      get('/usuarios/me/historial?pagina=1&limite=10'),
      get('/ranking/reciclador-mes'), 
    ]);

    final user = AppUser.fromJson(responses[0]);
    final metrics = responses[1];
    final ranking = responses[2];
    final history = responses[3];
    final recyclerJson = responses[4];

    final historyPage = _parseHistoryPage(history);
    final topData = ranking['usuario'];
    if (topData != null && topData is! Map<String, dynamic>) {
      throw const ApiException('El servidor devolvió datos incompletos.');
    }

    MonthlyRecycler? monthlyRecycler;
    final recyclerData = recyclerJson['data'] ?? recyclerJson;
    if (recyclerData is Map<String, dynamic>) {
      monthlyRecycler = MonthlyRecycler.fromJson(recyclerData);
    }

    return DashboardData(
      user: user,
      metrics: UserMetrics.fromJson(metrics),
      rankingPosition: topData is Map<String, dynamic>
          ? _intOrNull(topData['posicion'])
          : null,
      deliveries: historyPage.deliveries,
      historyTotal: historyPage.total,
      monthlyRecycler: monthlyRecycler,
    );
  }

  Future<HistoryPage> loadHistoryPage(int page) async {
    final result = await get('/usuarios/me/historial?pagina=$page&limite=10');
    return _parseHistoryPage(result);
  }

  Future> get(String path) =>
      _request('GET', path, authenticated: true);

  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future> _request(
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
    if (decoded is Map<String, dynamic>) return decoded;
    
    throw ApiException(
      'El servidor devolvió datos en un formato inesperado.',
      statusCode: response.statusCode,
    );
  }

  /// HU18: Obtiene las estadísticas personales y métricas de impacto ambiental
  Future> getPersonalEnvironmentalStats() async {
    final data = await _request(
      'GET',
      '/usuarios/me/metricas',
      authenticated: true,
    );
    return data;
  }

  Future<List<Achievement>> getUserAchievements() async {
    final data = await _request(
      'GET',
      '/logros',
      authenticated: true,
    );

    final listData = data['logros'] ?? data;
    if (listData is! List) {
      throw const ApiException('El servidor devolvió un formato de logros inválido.');
    }

    return listData
        .whereType>()
        .map((item) => Achievement.fromJson(item))
        .toList();
  }

  Future<List<MonthlyRecycler>> getMonthlyRecyclerData({String? mes}) async {
    final queryParameters = mes != null ? {'mes': mes} : null;

    final data = await _request(
      'GET',
      '/ranking/reciclador-mes',
      queryParameters: queryParameters,
      authenticated: true, 
    );

    final listData = data['data'] ?? data['ranking'] ?? data;
    
    if (listData is Map<String, dynamic>) {
      return [MonthlyRecycler.fromJson(listData)];
    }

    if (listData is! List) {
      throw const ApiException('El servidor devolvió un formato de datos mensuales inválido.');
    }

    return listData
        .whereType>()
        .map((item) => MonthlyRecycler.fromJson(item))
        .toList();
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
          .whereType>()
          .map(Delivery.fromJson)
          .toList(growable: false),
      historyTotal: total,
    );
  }
}
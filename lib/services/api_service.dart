import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/achievement.dart';
import '../models/dashboard_data.dart';
import '../models/delivery.dart';
import '../models/recycling_point.dart';
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
      throw const ApiException(
        'El servidor devolvió un formato de usuario inválido.',
      );
    }

    return AppUser.fromJson(userData);
  }

  Future<DashboardData> loadDashboard({int historyPages = 1}) async {
    final responses = await Future.wait<Object>([
      get('/usuarios'),
      get('/usuarios/me/metricas'),
      get('/ranking'),
      loadHistoryPages(historyPages),
      get('/ranking/reciclador-mes'),
    ]);

    final userJson = responses[0] as Map<String, dynamic>;
    final metrics = responses[1] as Map<String, dynamic>;
    final ranking = responses[2] as Map<String, dynamic>;
    final historyPage = responses[3] as HistoryPage;
    final recyclerJson = responses[4] as Map<String, dynamic>;

    final user = AppUser.fromJson(userJson);
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

  /// Reload every displayed page, so new records cannot duplicate rows at a
  /// pagination boundary or leave older pages permanently stale.
  Future<HistoryPage> loadHistoryPages(int count) async {
    if (count < 1) {
      throw ArgumentError.value(count, 'count', 'Must be positive');
    }
    final pages = await Future.wait([
      for (var page = 1; page <= count; page++) loadHistoryPage(page),
    ]);
    final ids = <String>{};
    return HistoryPage(
      deliveries: [
        for (final page in pages)
          for (final delivery in page.deliveries)
            if (delivery.id == null || ids.add(delivery.id!)) delivery,
      ],
      total: pages.first.total,
    );
  }

  Future<Map<String, dynamic>> get(String path) =>
      _request('GET', path, authenticated: true);

  Future<List<RecyclingPoint>> loadRecyclingPoints() async {
    final data = await _send('GET', '/tachos', authenticated: true);
    return _parsePoints(data);
  }

  Future<List<RecyclingPoint>> loadNearbyPoints({
    required double latitude,
    required double longitude,
    int radiusM = 5000,
  }) async {
    final data = await _send(
      'GET',
      '/tachos/cercanos?lat=$latitude&lng=$longitude&radio=$radiusM',
      authenticated: true,
    );
    return _parsePoints(data);
  }

  static List<RecyclingPoint> _parsePoints(dynamic data) {
    if (data is! List) {
      throw const ApiException('El servidor devolvió una lista inválida.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(RecyclingPoint.tryParse)
        .whereType<RecyclingPoint>()
        .toList(growable: false);
  }

  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, String>? queryParameters,
    required bool authenticated,
  }) async {
    final data = await _send(
      method,
      path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
    if (data is Map<String, dynamic>) return data;
    throw const ApiException(
      'El servidor devolvió datos en un formato inesperado.',
    );
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, String>? queryParameters,
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
    final pathUri = Uri.parse('$normalizedBase/$relativePath');
    final uri = queryParameters == null
        ? pathUri
        : pathUri.replace(
            queryParameters: {...pathUri.queryParameters, ...queryParameters},
          );
    late final http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 20));
    } on http.ClientException {
      throw ApiException(
        kDebugMode
            ? 'No se pudo conectar con $method $uri. '
                  'Comprueba que el backend esté encendido y la conexión USB esté configurada.'
            : 'No se pudo conectar con el servidor. Comprueba tu conexión.',
      );
    } on TimeoutException {
      throw ApiException(
        kDebugMode
            ? 'El servidor no respondió en 20 segundos: $method $uri. '
                  'Comprueba que el backend esté encendido y la conexión USB esté configurada.'
            : 'La solicitud tardó demasiado. Inténtalo otra vez.',
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
    if (data is Map<String, dynamic> || data is List) return data;
    return decoded;
  }

  /// HU18: Obtiene las estadísticas personales y métricas de impacto ambiental
  Future<Map<String, dynamic>> getPersonalEnvironmentalStats() async {
    final data = await _request(
      'GET',
      '/usuarios/me/metricas',
      authenticated: true,
    );
    return data;
  }

  Future<List<Achievement>> getUserAchievements() async {
    final data = await _send('GET', '/logros', authenticated: true);

    final listData = data is Map<String, dynamic>
        ? data['logros'] ?? data
        : data;
    if (listData is! List) {
      throw const ApiException(
        'El servidor devolvió un formato de logros inválido.',
      );
    }

    return listData
        .whereType<Map<String, dynamic>>()
        .map((item) => Achievement.fromJson(item))
        .toList();
  }

  Future<List<MonthlyRecycler>> getMonthlyRecyclerData({String? mes}) async {
    final queryParameters = mes != null ? {'mes': mes} : null;

    final data = await _send(
      'GET',
      '/ranking/reciclador-mes',
      queryParameters: queryParameters,
      authenticated: true,
    );

    final listData = data is Map<String, dynamic>
        ? data['data'] ?? data['ranking'] ?? data
        : data;

    if (listData is Map<String, dynamic>) {
      return [MonthlyRecycler.fromJson(listData)];
    }

    if (listData is! List) {
      throw const ApiException(
        'El servidor devolvió un formato de datos mensuales inválido.',
      );
    }

    return listData
        .whereType<Map<String, dynamic>>()
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
          .whereType<Map<String, dynamic>>()
          .map(Delivery.fromJson)
          .toList(growable: false),
      total: total,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/recycling_point.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

enum _LocationState {
  idle,
  loading,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

/// Mapa con los puntos de reciclaje (tachos) y la ubicación del usuario.
///
/// Los datos se cargan la primera vez que [active] pasa a `true`, para no
/// pedir el permiso de ubicación al abrir la app.
class MapScreen extends StatefulWidget {
  final bool active;

  const MapScreen({super.key, required this.active});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Campus de la Universidad de Lima; se usa si aún no hay puntos ni ubicación.
  static const _fallbackCenter = LatLng(-12.0854, -76.9714);
  static const _nearbyRadiusM = 5000;

  final MapController _mapController = MapController();

  bool _started = false;
  bool _mapReady = false;

  bool _loadingPoints = false;
  String? _pointsError;
  List<RecyclingPoint> _points = const [];

  _LocationState _locationState = _LocationState.idle;
  LatLng? _userLocation;
  List<RecyclingPoint> _nearby = const [];
  String? _nearbyError;

  RecyclingPoint? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_started) _start();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _start() {
    _started = true;
    _loadPoints();
    _locateUser();
  }

  // ---------------------------------------------------------------- datos

  Future<void> _loadPoints() async {
    setState(() {
      _loadingPoints = true;
      _pointsError = null;
    });
    try {
      final points = await ApiService.instance.loadRecyclingPoints();
      if (!mounted) return;
      setState(() {
        _points = points;
        _loadingPoints = false;
        // Conserva la selección solo si el punto sigue existiendo.
        final selectedId = _selected?.id;
        _selected = selectedId == null
            ? null
            : points.where((p) => p.id == selectedId).firstOrNull;
      });
      if (_userLocation == null) _fitToPoints();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingPoints = false;
        _pointsError = error.message;
      });
    }
  }

  Future<void> _locateUser() async {
    setState(() => _locationState = _LocationState.loading);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _setLocationState(_LocationState.serviceDisabled);
        return;
      }

      // 1. Solicitar permiso de ubicación.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _setLocationState(_LocationState.denied);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _setLocationState(_LocationState.deniedForever);
        return;
      }

      // 2. Obtener las coordenadas del dispositivo.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;

      // 3. Mostrar la ubicación actual en el mapa.
      final here = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = here;
        _locationState = _LocationState.granted;
      });
      _moveTo(here, 15);

      // 4. Presentar los puntos cercanos.
      await _loadNearby(here);
    } catch (_) {
      // Incluye TimeoutException y errores de plataforma.
      _setLocationState(_LocationState.error);
    }
  }

  Future<void> _loadNearby(LatLng here) async {
    try {
      final nearby = await ApiService.instance.loadNearbyPoints(
        latitude: here.latitude,
        longitude: here.longitude,
        radiusM: _nearbyRadiusM,
      );
      if (!mounted) return;
      setState(() {
        _nearby = nearby;
        _nearbyError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _nearbyError = error.message);
    }
  }

  void _setLocationState(_LocationState state) {
    if (!mounted) return;
    setState(() => _locationState = state);
  }

  Future<void> _refresh() async {
    await _loadPoints();
    final here = _userLocation;
    if (here != null) await _loadNearby(here);
  }

  // ---------------------------------------------------------------- mapa

  void _moveTo(LatLng target, double zoom) {
    if (!_mapReady) return;
    _mapController.move(target, zoom);
  }

  void _fitToPoints() {
    if (!_mapReady || _points.isEmpty) return;
    final coords = _points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);
    final latSpan =
        coords.map((c) => c.latitude).reduce((a, b) => a > b ? a : b) -
        coords.map((c) => c.latitude).reduce((a, b) => a < b ? a : b);
    final lngSpan =
        coords.map((c) => c.longitude).reduce((a, b) => a > b ? a : b) -
        coords.map((c) => c.longitude).reduce((a, b) => a < b ? a : b);
    if (latSpan < 0.0001 && lngSpan < 0.0001) {
      _mapController.move(coords.first, 16);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: coords,
        padding: const EdgeInsets.all(48),
        maxZoom: 17,
      ),
    );
  }

  void _select(RecyclingPoint point) {
    setState(() => _selected = point);
    _moveTo(LatLng(point.latitude, point.longitude), 17);
  }

  /// Une los datos del listado con la distancia calculada por el backend.
  RecyclingPoint _withKnownDistance(RecyclingPoint point) {
    if (point.distanceM != null) return point;
    final here = _userLocation;
    if (here == null) return point;
    return point.withDistance(
      Geolocator.distanceBetween(
        here.latitude,
        here.longitude,
        point.latitude,
        point.longitude,
      ),
    );
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMap()),
          _buildNearbyPanel(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 10),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntos de reciclaje',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Encuentra el tacho más cercano',
                  style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _loadingPoints ? null : _refresh,
            icon: const Icon(Icons.refresh, color: AppColors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final user = _userLocation;
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: user ?? _fallbackCenter,
            initialZoom: 15,
            minZoom: 3,
            maxZoom: 19,
            onMapReady: () {
              _mapReady = true;
              if (_userLocation != null) {
                _moveTo(_userLocation!, 15);
              } else {
                _fitToPoints();
              }
            },
            onTap: (_, _) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.frontendmovil',
            ),
            MarkerLayer(
              markers: [
                for (final point in _points)
                  Marker(
                    point: LatLng(point.latitude, point.longitude),
                    width: 44,
                    height: 44,
                    child: _PointMarker(
                      point: point,
                      selected: point.id == _selected?.id,
                      onTap: () => _select(_withKnownDistance(point)),
                    ),
                  ),
                if (user != null)
                  Marker(
                    point: user,
                    width: 28,
                    height: 28,
                    child: const _UserMarker(),
                  ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [TextSourceAttribution('© OpenStreetMap')],
            ),
          ],
        ),
        if (_loadingPoints)
          const Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(child: _Pill(child: _Spinner(label: 'Cargando…'))),
          ),
        if (_pointsError != null)
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: _ErrorBanner(message: _pointsError!, onRetry: _loadPoints),
          ),
        Positioned(
          right: 12,
          bottom: _selected == null ? 12 : 140,
          child: FloatingActionButton.small(
            heroTag: 'locate-me',
            tooltip: 'Mi ubicación',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.orange,
            onPressed: () {
              final here = _userLocation;
              if (here != null) {
                _moveTo(here, 16);
              } else {
                _locateUser();
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ),
        if (_selected != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _PointDetailCard(
              point: _selected!,
              onClose: () => setState(() => _selected = null),
            ),
          ),
      ],
    );
  }

  Widget _buildNearbyPanel() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 210),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: switch (_locationState) {
        _LocationState.idle || _LocationState.loading => const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: _Spinner(label: 'Obteniendo tu ubicación…')),
        ),
        _LocationState.granted => _buildNearbyList(),
        _LocationState.denied => _LocationPrompt(
          message:
              'Necesitamos tu permiso de ubicación para mostrarte los '
              'puntos cercanos.',
          actionLabel: 'Permitir ubicación',
          onAction: _locateUser,
        ),
        _LocationState.deniedForever => _LocationPrompt(
          message:
              'El permiso de ubicación está bloqueado. Actívalo en los '
              'ajustes de la app.',
          actionLabel: 'Abrir ajustes',
          onAction: Geolocator.openAppSettings,
        ),
        _LocationState.serviceDisabled => _LocationPrompt(
          message: 'Activa la ubicación (GPS) de tu dispositivo.',
          actionLabel: 'Abrir ajustes de ubicación',
          onAction: Geolocator.openLocationSettings,
        ),
        _LocationState.error => _LocationPrompt(
          message: 'No se pudo obtener tu ubicación.',
          actionLabel: 'Reintentar',
          onAction: _locateUser,
        ),
      },
    );
  }

  Widget _buildNearbyList() {
    if (_nearbyError != null) {
      return _LocationPrompt(
        message: _nearbyError!,
        actionLabel: 'Reintentar',
        onAction: () {
          final here = _userLocation;
          if (here != null) _loadNearby(here);
        },
      );
    }
    if (_nearby.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No hay puntos de reciclaje a menos de 5 km de ti.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cerca de ti (${_nearby.length})',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _nearby.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final point = _nearby[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                onTap: () => _select(point),
                leading: Icon(
                  Icons.recycling,
                  color: point.isFull ? AppColors.orange : AppColors.green,
                ),
                title: Text(
                  'Tacho #${point.id} · ${point.typeLabel}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  point.statusLabel,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Text(
                  point.distanceLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ componentes

class _PointMarker extends StatelessWidget {
  final RecyclingPoint point;
  final bool selected;
  final VoidCallback onTap;

  const _PointMarker({
    required this.point,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = point.isFull ? AppColors.orange : AppColors.green;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: selected ? 4 : 2),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 6),
          ],
        ),
        child: const Icon(Icons.recycling, color: Colors.white, size: 22),
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 6)],
      ),
    );
  }
}

class _PointDetailCard extends StatelessWidget {
  final RecyclingPoint point;
  final VoidCallback onClose;

  const _PointDetailCard({required this.point, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final color = point.isFull ? AppColors.orange : AppColors.green;
    final fill = point.fillPercent;
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tacho #${point.id}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Cerrar',
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            Text(
              'Tipo: ${point.typeLabel}',
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: point.isFull
                        ? AppColors.orangeSoft
                        : AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    point.statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                if (fill != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    'Llenado: ${fill.round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
                if (point.distanceM != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    'A ${point.distanceLabel}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPrompt extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _LocationPrompt({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.location_on_outlined, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      color: AppColors.orangeSoft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;

  const _Pill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: child,
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  final String label;

  const _Spinner({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
      ],
    );
  }
}

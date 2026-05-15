import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_campus/providers/navigation_provider.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  final LatLng _campusCenter = const LatLng(31.4621, 73.1485);

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Route Selection Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Your Route',
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Start Location',
                          prefixIcon: Icon(
                            Icons.my_location,
                            color: Colors.green,
                          ),
                          isDense: true,
                        ),
                        isExpanded: true,
                        initialValue: nav.startLocation,
                        items: nav.buildingNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => nav.setStart(val),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Destination',
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                          isDense: true,
                        ),
                        isExpanded: true,
                        initialValue: nav.endLocation,
                        items: nav.buildingNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => nav.setEnd(val),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: nav.isLoadingRoute
                                  ? null
                                  : () async {
                                      final error = await nav.calculateRoute();
                                      if (!context.mounted) return;
                                      if (error != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(error),
                                            backgroundColor:
                                                theme.colorScheme.error,
                                          ),
                                        );
                                      } else if (nav.routePoints.isNotEmpty) {
                                        final bounds = LatLngBounds.fromPoints(
                                          nav.routePoints,
                                        );
                                        _mapController.fitCamera(
                                          CameraFit.bounds(
                                            bounds: bounds,
                                            padding: const EdgeInsets.all(60),
                                          ),
                                        );
                                      }
                                    },
                              icon: nav.isLoadingRoute
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.directions_walk, size: 18),
                              label: Text(
                                nav.isLoadingRoute
                                    ? 'Finding...'
                                    : 'Find Route',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => nav.clearRoute(),
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear Route',
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.errorContainer,
                            ),
                          ),
                        ],
                      ),
                      // Distance info
                      if (nav.distance != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _InfoChip(
                                  icon: Icons.straighten,
                                  label:
                                      '${nav.distance!.toStringAsFixed(0)} m',
                                ),
                                _InfoChip(
                                  icon: Icons.timer,
                                  label:
                                      '${nav.estimatedTimeMinutes!.toStringAsFixed(1)} min',
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Category filter chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: nav.categories.map((cat) {
                  final isSelected =
                      nav.selectedCategory == cat ||
                      (nav.selectedCategory == null && cat == 'all');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat[0].toUpperCase() + cat.substring(1)),
                      selected: isSelected,
                      onSelected: (_) => nav.setCategory(cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Map
            Expanded(
              child: Listener(
                onPointerPanZoomUpdate: (event) {
                  // Modern trackpads fire this event for two-finger scrolling
                  final camera = _mapController.camera;
                  final double degreesPerPixel =
                      360 / (256 * (1 << camera.zoom.toInt()));
                  final newLat =
                      camera.center.latitude - (event.panDelta.dy * degreesPerPixel * 1.5);
                  final newLng =
                      camera.center.longitude + (event.panDelta.dx * degreesPerPixel * 1.5);
                  _mapController.move(LatLng(newLat, newLng), camera.zoom);
                },
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final delta = event.scrollDelta;
                    
                    bool isTrackpad = event.kind == PointerDeviceKind.trackpad;
                    if (!isTrackpad && event.kind == PointerDeviceKind.mouse) {
                      // Mouse wheel deltas are typically exactly 50, 100, 120.
                      // Trackpads (even when fast) produce fractional/continuous deltas.
                      if (delta.dy % 10 != 0 || delta.dy.abs() < 40 || delta.dx != 0) {
                        isTrackpad = true;
                      }
                    }

                    if (!isTrackpad) {
                      // Zoom map (Mouse Wheel)
                      final zoomDelta = delta.dy > 0 ? -0.5 : 0.5;
                      final newZoom = (_mapController.camera.zoom + zoomDelta)
                          .clamp(16.0, 22.0);
                      _mapController.move(
                        _mapController.camera.center,
                        newZoom,
                      );
                    } else {
                      // Pan map (Trackpad scroll)
                      final camera = _mapController.camera;
                      final double degreesPerPixel =
                          360 / (256 * (1 << camera.zoom.toInt()));
                      final newLat =
                          camera.center.latitude - (delta.dy * degreesPerPixel * 1.5);
                      final newLng =
                          camera.center.longitude +
                          (delta.dx * degreesPerPixel * 1.5);
                      _mapController.move(LatLng(newLat, newLng), camera.zoom);
                    }
                  }
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _campusCenter,
                      initialZoom: 17.0,
                      minZoom: 16.0,
                      maxZoom: 22.0,
                      cameraConstraint: CameraConstraint.containCenter(
                        bounds: LatLngBounds(
                          const LatLng(31.4600, 73.1460), // SouthWest Campus Edge
                          const LatLng(31.4645, 73.1505), // NorthEast Campus Edge
                        ),
                      ),
                      interactionOptions: const InteractionOptions(
                        flags:
                            InteractiveFlag.all &
                            ~InteractiveFlag.scrollWheelZoom,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: theme.brightness == Brightness.dark
                            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                            : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.example.smart_campus',
                        maxNativeZoom: 19,
                      ),
                      if (!kIsWeb) CurrentLocationLayer(),
                      if (nav.routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: nav.routePoints,
                              strokeWidth: 5,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      Builder(
                        builder: (context) {
                          final currentZoom = MapCamera.of(context).zoom;
                          return MarkerLayer(
                            markers: nav.filteredBuildings.map((building) {
                              Color color = Colors.blue;
                              double size = 28;
                              if (building.name == nav.startLocation) {
                                color = Colors.green;
                                size = 40;
                              }
                              if (building.name == nav.endLocation) {
                                color = Colors.red;
                                size = 40;
                              }
                              return Marker(
                                point: building.location,
                                width: 120,
                                height: 80,
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/building',
                                    arguments: building.name,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: color,
                                        size: size,
                                      ),
                                      if (currentZoom >= 17.5)
                                        Positioned(
                                          bottom: 40 + (size / 2) - 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surface.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: Text(
                                              building.name,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.onSurface,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'resetView',
            mini: true,
            onPressed: () {
              // Reset to campus center and default zoom (1 level inside the 16.0 limit)
              _mapController.move(_campusCenter, 17.0);
            },
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom + 1,
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom - 1,
              );
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

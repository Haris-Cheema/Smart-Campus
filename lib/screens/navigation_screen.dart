import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nav = context.watch<NavigationProvider>();

    return SafeArea(
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
                    Text('Find Your Route', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Start Location',
                        prefixIcon: Icon(Icons.my_location, color: Colors.green),
                        isDense: true,
                      ),
                      isExpanded: true,
                      value: nav.startLocation,
                      items: nav.buildingNames.map((name) {
                        return DropdownMenuItem(value: name, child: Text(name, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) => nav.setStart(val),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        prefixIcon: Icon(Icons.location_on, color: Colors.red),
                        isDense: true,
                      ),
                      isExpanded: true,
                      value: nav.endLocation,
                      items: nav.buildingNames.map((name) {
                        return DropdownMenuItem(value: name, child: Text(name, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) => nav.setEnd(val),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final error = nav.calculateRoute();
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error), backgroundColor: theme.colorScheme.error),
                                );
                              } else if (nav.routePoints.isNotEmpty) {
                                final bounds = LatLngBounds.fromPoints(nav.routePoints);
                                _mapController.fitCamera(
                                  CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
                                );
                              }
                            },
                            icon: const Icon(Icons.directions_walk, size: 18),
                            label: const Text('Find Route'),
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
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _InfoChip(icon: Icons.straighten, label: '${nav.distance!.toStringAsFixed(0)} m'),
                              _InfoChip(icon: Icons.timer, label: '${nav.estimatedTimeMinutes!.toStringAsFixed(1)} min'),
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
                final isSelected = nav.selectedCategory == cat || (nav.selectedCategory == null && cat == 'all');
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
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: _campusCenter, initialZoom: 17.0),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.smart_campus',
                  ),
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
                  MarkerLayer(
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
                        width: size,
                        height: size,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/building', arguments: building.name),
                          child: Icon(Icons.location_on, color: color, size: size),
                        ),
                      );
                    }).toList(),
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

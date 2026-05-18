import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus/providers/navigation_provider.dart';

class BuildingDetailScreen extends StatelessWidget {
  const BuildingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buildingName = ModalRoute.of(context)!.settings.arguments as String;
    final nav = context.read<NavigationProvider>();
    final building = nav.getBuildingByName(buildingName);

    if (building == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Building Not Found')),
        body: const Center(child: Text('Building not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(building.name)),
      body: ListView(
        children: [
          SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: building.location,
                initialZoom: 18,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: theme.brightness == Brightness.dark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.smart_campus',
                  keepBuffer: 3,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: building.location,
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.location_on,
                        color: theme.colorScheme.primary,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (building.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _categoryColor(
                        building.category!,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      building.category!.toUpperCase(),
                      style: TextStyle(
                        color: _categoryColor(building.category!),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                Text(building.name, style: theme.textTheme.displayMedium),
                const SizedBox(height: 12),

                if (building.description != null) ...[
                  Text(building.description!, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 20),
                ],

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.location_on,
                          label: 'Latitude',
                          value: building.location.latitude.toStringAsFixed(6),
                        ),
                        const Divider(),
                        _DetailRow(
                          icon: Icons.location_on,
                          label: 'Longitude',
                          value: building.location.longitude.toStringAsFixed(6),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    nav.setEnd(building.name);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate Here'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'academic':
        return const Color(0xFF004AAD);
      case 'admin':
        return const Color(0xFF006397);
      case 'sports':
        return const Color(0xFF28A745);
      case 'hostel':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

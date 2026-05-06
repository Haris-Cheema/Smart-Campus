import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final Map<String, LatLng> buildings = {
    "Parking": const LatLng(31.460817, 73.147092),
    "Play Ground": const LatLng(31.461333, 73.148057),
    "NTU Admission office": const LatLng(31.461562, 73.148298),
    "library": const LatLng(31.461816, 73.147634),
    "Department of textile Technology": const LatLng(31.461902, 73.147973),
    "University Auditorium": const LatLng(31.461933, 73.148319),
    "Rector office": const LatLng(31.461987, 73.148704),
    "CECA": const LatLng(31.462070, 73.148299),
    "Weaving Lab": const LatLng(31.462256, 73.147691),
    "Weaving Department": const LatLng(31.462093, 73.147740),
    "Garments": const LatLng(31.462274, 73.147793),
    "Mechanical lab": const LatLng(31.462218, 73.147487),
    "Knitting Department": const LatLng(31.462134, 73.147075),
    "Polymer Engineers": const LatLng(31.462325, 73.146999),
    "School of Engineering and Technology": const LatLng(31.462685, 73.147575),
    "IT Center": const LatLng(31.462808, 73.148879),
    "School of Arts and Design": const LatLng(31.463034, 73.149252),
    "student advisor office": const LatLng(31.462306, 73.148804),
    "Dispensary": const LatLng(31.462926, 73.149671),
    "Cricket ground": const LatLng(31.463531, 73.148670),
    "Girls Hostel": const LatLng(31.464066, 73.150130),
    "Masjid": const LatLng(31.463238, 73.147542),
    "Faisalabad business school (FBS)": const LatLng(31.462664, 73.149382),
    "New Boys Hostel": const LatLng(31.463223, 73.146757),
    "Old Boys Hostel": const LatLng(31.464183, 73.146086),
    "Hockey Ground": const LatLng(31.461641, 73.149417),
    "Cafeteria": const LatLng(31.462919, 73.148074),
    "Open Gym": const LatLng(31.463379, 73.147318),
  };

  String? _startLocation;
  String? _endLocation;
  final LatLng _campusCenter = const LatLng(31.462140, 73.148536);
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];

  void _calculateRoute() {
    if (_startLocation != null && _endLocation != null && _startLocation != _endLocation) {
      setState(() {
        _routePoints = [
          buildings[_startLocation]!,
          buildings[_endLocation]!,
        ];
      });
      // Zoom to fit bounds
      final bounds = LatLngBounds.fromPoints(_routePoints);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
    } else if (_startLocation == _endLocation && _startLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start and Destination cannot be the same!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Start Location', prefixIcon: Icon(Icons.my_location)),
                      value: _startLocation,
                      items: buildings.keys.map((String key) {
                        return DropdownMenuItem<String>(value: key, child: Text(key, style: const TextStyle(fontSize: 14)));
                      }).toList(),
                      onChanged: (value) => setState(() => _startLocation = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Destination', prefixIcon: Icon(Icons.location_on)),
                      value: _endLocation,
                      items: buildings.keys.map((String key) {
                        return DropdownMenuItem<String>(value: key, child: Text(key, style: const TextStyle(fontSize: 14)));
                      }).toList(),
                      onChanged: (value) => setState(() => _endLocation = value),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _calculateRoute,
                      icon: const Icon(Icons.directions_walk),
                      label: const Text('Find Route'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _campusCenter,
                  initialZoom: 17.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.smart_campus',
                  ),
                  PolylineLayer(
                    polylines: [
                      if (_routePoints.isNotEmpty)
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 5.0,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: buildings.entries.map((entry) {
                      Color markerColor = Colors.blue;
                      if (entry.key == _startLocation) markerColor = Colors.green;
                      if (entry.key == _endLocation) markerColor = Colors.red;

                      return Marker(
                        point: entry.value,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: markerColor,
                          size: (entry.key == _startLocation || entry.key == _endLocation) ? 40 : 24,
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

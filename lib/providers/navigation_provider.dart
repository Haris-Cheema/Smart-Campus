import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_campus/models/building_model.dart';

class NavigationProvider extends ChangeNotifier {
  static final List<BuildingModel> _allBuildings = [
    BuildingModel(
      name: "Parking",
      location: const LatLng(31.46081, 73.14709),
      category: 'other',
      description: 'Main campus parking area near the south entrance.',
    ),
    BuildingModel(
      name: "Play Ground",
      location: const LatLng(31.46133, 73.14805),
      category: 'sports',
      description: 'General purpose playing field.',
    ),
    BuildingModel(
      name: "NTU Admission Office",
      location: const LatLng(31.46156, 73.14829),
      category: 'admin',
      description: 'Handles all admission queries and applications.',
    ),
    BuildingModel(
      name: "Library",
      location: const LatLng(31.46181, 73.14763),
      category: 'academic',
      description: 'Central library with 50,000+ books and digital resources.',
    ),
    BuildingModel(
      name: "Dept. of Textile Technology",
      location: const LatLng(31.46190, 73.14797),
      category: 'academic',
      description: 'Department of Textile Technology — core NTU department.',
    ),
    BuildingModel(
      name: "University Auditorium",
      location: const LatLng(31.46193, 73.14831),
      category: 'admin',
      description: 'Main auditorium for events, seminars, and convocations.',
    ),
    BuildingModel(
      name: "Rector Office",
      location: const LatLng(31.46198, 73.14870),
      category: 'admin',
      description: 'Office of the Rector / Vice Chancellor.',
    ),
    BuildingModel(
      name: "CECA",
      location: const LatLng(31.46207, 73.14829),
      category: 'academic',
      description: 'Centre for Engineering, Civil & Architecture.',
    ),
    BuildingModel(
      name: "Weaving Lab",
      location: const LatLng(31.46225, 73.14769),
      category: 'academic',
      description: 'Practical weaving laboratory.',
    ),
    BuildingModel(
      name: "Weaving Department",
      location: const LatLng(31.46209, 73.14774),
      category: 'academic',
      description: 'Academic department for weaving studies.',
    ),
    BuildingModel(
      name: "Garments",
      location: const LatLng(31.46227, 73.14779),
      category: 'academic',
      description: 'Garment manufacturing department.',
    ),
    BuildingModel(
      name: "Mechanical Lab",
      location: const LatLng(31.46221, 73.14748),
      category: 'academic',
      description: 'Mechanical engineering laboratory.',
    ),
    BuildingModel(
      name: "Knitting Department",
      location: const LatLng(31.46213, 73.14707),
      category: 'academic',
      description: 'Knitting technology department.',
    ),
    BuildingModel(
      name: "Polymer Engineers",
      location: const LatLng(31.46232, 73.14699),
      category: 'academic',
      description: 'Polymer engineering department.',
    ),
    BuildingModel(
      name: "School of Engineering & Tech",
      location: const LatLng(31.46268, 73.14757),
      category: 'academic',
      description: 'Main engineering and technology faculty building.',
    ),
    BuildingModel(
      name: "IT Center",
      location: const LatLng(31.46280, 73.14887),
      category: 'academic',
      description: 'Computer labs, IT support, and network management.',
    ),
    BuildingModel(
      name: "School of Arts & Design",
      location: const LatLng(31.46303, 73.14925),
      category: 'academic',
      description: 'Faculty of Arts and Design.',
    ),
    BuildingModel(
      name: "Student Advisor Office",
      location: const LatLng(31.46230, 73.14880),
      category: 'admin',
      description: 'Student advisory and counseling services.',
    ),
    BuildingModel(
      name: "Dispensary",
      location: const LatLng(31.46292, 73.14967),
      category: 'other',
      description: 'Campus medical facility with basic healthcare.',
    ),
    BuildingModel(
      name: "Cricket Ground",
      location: const LatLng(31.46353, 73.14867),
      category: 'sports',
      description: 'Full-size cricket ground.',
    ),
    BuildingModel(
      name: "Girls Hostel",
      location: const LatLng(31.46406, 73.15013),
      category: 'hostel',
      description: 'Female students residential hostel.',
    ),
    BuildingModel(
      name: "Masjid",
      location: const LatLng(31.46323, 73.14754),
      category: 'other',
      description: 'Campus mosque. Friday prayers at 1:00 PM.',
    ),
    BuildingModel(
      name: "FBS (Business School)",
      location: const LatLng(31.46266, 73.14938),
      category: 'academic',
      description: 'Faisalabad Business School — MBA and BBA programs.',
    ),
    BuildingModel(
      name: "New Boys Hostel",
      location: const LatLng(31.46322, 73.14675),
      category: 'hostel',
      description: 'New male students residential hostel.',
    ),
    BuildingModel(
      name: "Football Ground",
      location: const LatLng(31.46384, 73.14687),
      category: 'sports',
      description: 'Football / Soccer playing field.',
    ),
    BuildingModel(
      name: "Badminton Ground",
      location: const LatLng(31.46382, 73.14616),
      category: 'sports',
      description: 'Badminton courts.',
    ),
    BuildingModel(
      name: "Old Boys Hostel",
      location: const LatLng(31.46418, 73.14608),
      category: 'hostel',
      description: 'Original male students residential hostel.',
    ),
    BuildingModel(
      name: "Hockey Ground",
      location: const LatLng(31.46164, 73.14941),
      category: 'sports',
      description: 'Hockey playing field.',
    ),
    BuildingModel(
      name: "Cafeteria",
      location: const LatLng(31.46291, 73.14807),
      category: 'other',
      description: 'Main campus cafeteria — open 8 AM to 6 PM.',
    ),
    BuildingModel(
      name: "Open Gym",
      location: const LatLng(31.46337, 73.14731),
      category: 'sports',
      description: 'Outdoor gym equipment area.',
    ),
    BuildingModel(
      name: "Main Gate",
      location: const LatLng(31.461123, 73.148778),
      category: 'other',
      description:
          'The primary entrance and security checkpoint of the campus.',
    ),
    BuildingModel(
      name: "Parking Gate",
      location: const LatLng(31.460681, 73.146727),
      category: 'other',
      description: 'The entrance gate for parking of the campus.',
    ),
    BuildingModel(
      name: "National Textile Research Labs",
      location: const LatLng(31.460583, 73.148322),
      category: 'academic',
      description: 'National Textile Research Labs.',
    ),
  ]..sort((a, b) => a.name.compareTo(b.name));

  String? _startLocation;
  String? _endLocation;
  List<LatLng> _routePoints = [];
  double? _distance;
  String? _selectedCategory;

  List<BuildingModel> get allBuildings => _allBuildings;
  String? get startLocation => _startLocation;
  String? get endLocation => _endLocation;
  List<LatLng> get routePoints => _routePoints;
  double? get distance => _distance;
  String? get selectedCategory => _selectedCategory;

  List<BuildingModel> get filteredBuildings {
    if (_selectedCategory == null || _selectedCategory == 'all') {
      return _allBuildings;
    }
    return _allBuildings.where((b) => b.category == _selectedCategory).toList();
  }

  List<String> get buildingNames => _allBuildings.map((b) => b.name).toList();

  List<String> get categories => [
    'all',
    'academic',
    'admin',
    'sports',
    'hostel',
    'other',
  ];

  BuildingModel? getBuildingByName(String name) {
    try {
      return _allBuildings.firstWhere((b) => b.name == name);
    } catch (e) {
      return null;
    }
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStart(String? location) {
    _startLocation = location;
    notifyListeners();
  }

  void setEnd(String? location) {
    _endLocation = location;
    notifyListeners();
  }

  bool _isLoadingRoute = false;
  bool get isLoadingRoute => _isLoadingRoute;

  // Calculate route — returns error message or null on success
  Future<String?> calculateRoute() async {
    if (_startLocation == null || _endLocation == null) {
      return 'Please select both start and destination';
    }
    if (_startLocation == _endLocation) {
      return 'Start and Destination cannot be the same!';
    }

    final startBuilding = getBuildingByName(_startLocation!);
    final endBuilding = getBuildingByName(_endLocation!);
    if (startBuilding == null || endBuilding == null) {
      return 'Invalid building selection';
    }

    _isLoadingRoute = true;
    notifyListeners();

    try {
      final startLon = startBuilding.location.longitude;
      final startLat = startBuilding.location.latitude;
      final endLon = endBuilding.location.longitude;
      final endLat = endBuilding.location.latitude;

      // Use OSRM public API for walking route
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/foot/$startLon,$startLat;$endLon,$endLat?geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];

          // Parse distance (in meters) and duration (in seconds)
          _distance = route['distance'].toDouble();
          _estimatedTimeMinutes = route['duration'] / 60.0;

          // Parse geometry points
          final geometry = route['geometry']['coordinates'] as List;
          _routePoints = geometry
              .map((point) => LatLng(point[1].toDouble(), point[0].toDouble()))
              .toList();

          _isLoadingRoute = false;
          notifyListeners();
          return null; // success
        }
      }

      // Fallback to straight line if API fails or returns no route
      _routePoints = [startBuilding.location, endBuilding.location];
      const Distance distanceCalc = Distance();
      _distance = distanceCalc.as(
        LengthUnit.Meter,
        startBuilding.location,
        endBuilding.location,
      );
      _estimatedTimeMinutes = (_distance! / 1.4) / 60; // walking speed ~1.4 m/s

      _isLoadingRoute = false;
      notifyListeners();
      return 'Could not find a walking path. Showing straight line instead.';
    } catch (e) {
      _isLoadingRoute = false;
      notifyListeners();
      return 'Error calculating route: $e';
    }
  }

  double? _estimatedTimeMinutes;
  double? get estimatedTimeMinutes => _estimatedTimeMinutes;

  void clearRoute() {
    _routePoints = [];
    _distance = null;
    _startLocation = null;
    _endLocation = null;
    notifyListeners();
  }
}
